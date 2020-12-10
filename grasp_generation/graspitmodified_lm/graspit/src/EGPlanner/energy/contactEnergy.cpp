
#include <Python.h>
#include "graspit/EGPlanner/energy/contactEnergy.h"
#include "graspit/robot.h"
#include "graspit/grasp.h"
#include "graspit/debug.h"
#include "graspit/world.h"
#include "graspit/contact/virtualContact.h"
#include "graspit/quality/quality.h"
#include <iostream>
#include <string.h>
/**
 * @brief This formulation combines virtual contact energy with autograsp energy. In addition, it computes EBM-based energy to access human-like grasping. 
    Virtual contact energy is used to "guide" initial stages of the search and to see if we should even bother computing autograsp quality. 
    Autograsp is a couple of orders of magnitude higher and so should work very well with later stages of the sim ann search.
    EBM-based energy is used to guide human-like grasping generation. This energy is computed by EBM learning model.
    Note that, EBM-based energy is implementation based on python, so we need to write an interface to run python script.
 * @author Jian Liu
 * 
 */
PyObject *pModule = NULL;
PyObject *pFunc = NULL;
PyObject *pDict = NULL;
PyObject *pReturn = NULL;

double
ContactEnergy::energy() const
{
  //first compute regular contact energy; also count how many links are "close" to the object
  if (mContactType == CONTACT_LIVE && mType != "AUTO_GRASP_QUALITY_ENERGY" && mType != "STRICT_AUTO_GRASP_ENERGY")
  {
    mHand->getWorld()->findVirtualContacts(mHand, mObject);
    DBGP("Live contacts computation");
  }

  mHand->getGrasp()->collectVirtualContacts();

  //DBGP("Contact energy computation")
  //average error per contact
  VirtualContact *contact;
  vec3 p, n, cn;
  double virtualError = 0; int closeContacts = 0;
  for (int i = 0; i < mHand->getGrasp()->getNumContacts(); i++)
  {
    contact = (VirtualContact *)mHand->getGrasp()->getContact(i);
    contact->getObjectDistanceAndNormal(mObject, &p, NULL);
    double dist = p.norm();

    //BEST WORKING VERSION, strangely enough
    virtualError += fabs(dist);

    //new version
    cn = contact->getWorldNormal();
    n = p.normalized();
    double d = 1 - cn.dot(n);
    virtualError += d * 100.0 / 2.0;

    if (fabs(dist) < 20 && d < 0.3) { closeContacts++; }
  }

  virtualError /= mHand->getGrasp()->getNumContacts();

  //double *dofVals = new double[mHand->getNumDOF()];
  double dofVals[mHand->getNumDOF()];
  mHand->getDOFVals(dofVals);
  double ebmQuality = 0;
  
  // std::cout<<mHand->getNumDOF()<<std::endl;
  // for(int i=0;i<mHand->getNumDOF();i++){
  //   std::cout<<dofVals[i]<<std::endl;
  //   }
  // std::cout<<mHand->getEBMPath()<<std::endl;
  //ebmQuality = this->ebm_pythonInterface(dofVals,mHand->getNumDOF(),mHand->getEBMPath());
  ebmQuality = this->method1(dofVals,mHand->getNumDOF(),mHand->getEBMPath());
  //delete []dofVals;
  //virtualError = virtualError + ebmQuality * 1.0e3;
  std::cout<<"contact energy: "<<virtualError<<std::endl;
  std::cout<<"ebm energy: "<<ebmQuality * 1000.0<<std::endl;
  std::cin.get();
  //if more than 2 links are "close" go ahead and compute the true quality
  // double volQuality = 0, epsQuality = 0;
  // if (closeContacts >= 2) 
  // {
  //   mHand->autoGrasp(false, 1.0);
  //   //now collect the true contacts;
  //   mHand->getGrasp()->collectContacts();
  //   if (mHand->getGrasp()->getNumContacts() >= 4) 
  //   {
  //     mHand->getGrasp()->updateWrenchSpaces();
  //     volQuality = mVolQual->evaluate();
  //     epsQuality = mEpsQual->evaluate();
  //     if (epsQuality < 0) { epsQuality = 0; } //QM returns -1 for non-FC grasps
  //   }

  //   DBGP("Virtual error " << virtualError << " and " << closeContacts << " close contacts.");
  //   DBGP("Volume quality: " << volQuality << " Epsilon quality: " << epsQuality);
  //   DBGP("Human-like quality: " << ebmQuality);
  // }
  return virtualError;
  // if (volQuality == 0) { q = virtualError + ebmQuality * 1.0e3; }
  // else { q = virtualError - volQuality * 1.0e3 + ebmQuality * 1.0e3; }
  // if (volQuality || epsQuality) {DBGP("Final quality: " << q);}

  // //DBGP("Final value: " << q << std::endl);
  // return q;
}

double
ContactEnergy::method1(double* dofVals, int numDOF, std::string modelPath) const
{
  	Py_Initialize();
	if(!Py_IsInitialized())
	{
		std::cout<<"Error: python init failed!"<<std::endl;
		return 0;
	}
	else
	{
		std::cout<<"python init successful"<<std::endl;
	}

  // PyRun_SimpleString("import torch");
  PyRun_SimpleString("import sys");
  // PyRun_SimpleString("import numpy as np");
  PyRun_SimpleString("sys.path.append('/home/liujian/WorkSpace/EBM_Hand')");
  // PyRun_SimpleString("from models import FCNet");

  pModule = PyImport_ImportModule("ebmPythonInterface");
  
	if(!pModule)
	{
		std::cout<<"Error: python module is null!"<<std::endl;
		return 0;
	}
	else
	{
		std::cout<<"python module is successful"<<std::endl;
	}

  pFunc = PyObject_GetAttrString(pModule,"dof_ebm");
	if(!pFunc)
	{
		std::cout<<"Error: python pFunc_dof_ebm is null!"<<std::endl;
		return 0;
	}
	else
	{
		std::cout<<"python pFunc_dof_ebm is successful"<<std::endl;
	}

   //创建参数:
  PyObject *pArgs = PyTuple_New(2); //函数调用的参数传递均是以元组的形式打包的,2表示参数个数
  PyObject *list_dof = PyList_New(0);

  for(int i=0; i<numDOF; i++)
  {
   double degVal = dofVals[i]*57.3;
   //std::cout<<degVal<<std::endl;
   PyList_Append(list_dof,Py_BuildValue("d",degVal));
  }
  
  PyTuple_SetItem(pArgs,0,list_dof);
  
  char* p = new char[100];p = strcpy(p,modelPath.c_str());
  //std::cout<<p<<std::endl;
  PyTuple_SetItem(pArgs,1,Py_BuildValue("s",p));

  //返回值
  pReturn = PyEval_CallObject(pFunc, pArgs); //调用函数
  //Py_DECREF(pFunc);
  //将返回值转换为double类型
  double result;
  PyArg_Parse(pReturn, "d", &result); //d表示转换成double型变量
  std::cout<<"ebm value: "<<result<<std::endl;
  Py_Finalize();
  return result;
}

double
ContactEnergy::ebm_pythonInterface(double* dofVals, int numDOF, std::string modelPath) const
{
  Py_Initialize();
  if (!Py_IsInitialized())
	{
		std::cout << "Failed to initialize" << std::endl;
		return 0;
	}
  PyRun_SimpleString("import sys");
  PyRun_SimpleString("sys.path.append('./')");//python脚本路径, 放在cpp的同一路径下
  PyRun_SimpleString("sys.path.append('/home/liujian/WorkSpace/EBM_Hand')");
  //PyRun_SimpleString("sys.path.append('/home/liujian/WorkSpace/EBM_Hand/grasp_generation/graspitmodified_lm/graspit/src/EGPlanner/energy/')");//python脚本路径, 放在cpp的同一路径下
  //PyRun_SimpleString("print(sys.path)");
  //PyRun_SimpleString("import ebmPythonInterface");

  pModule = PyImport_ImportModule("ebmPythonInterface");//Python文件名

  if (!pModule)
	{
		std::cout << "Cannot find ebmPythonInterface.py" << std::endl;
    return 0;
	}

  pDict = PyModule_GetDict(pModule);//加载文件中的函数名
	if (!pDict)
	{
		std::cout << "Cant find dictionary" << std::endl;
		return 0;
  }
  
	pFunc = PyDict_GetItemString(pDict, "dof_ebm");//根据函数名获得函数功能块，‘dof_ebm‘为Python中定义的函数名
	if (!pFunc)
	{
		printf("Cant find Function. dof_ebm /n");
    return 0;
	}


  pFunc = PyObject_GetAttrString(pModule, "dof_ebm"); //Python文件中的函数名
  //创建参数:
  PyObject *pArgs = PyTuple_New(2); //函数调用的参数传递均是以元组的形式打包的,2表示参数个数
  PyObject *list_dof = PyList_New(0);

  for(int i=0; i<numDOF; i++)
  {
   PyList_Append(list_dof,Py_BuildValue("d",dofVals[i]*57.3));
  }
  
  PyTuple_SetItem(pArgs,0,list_dof);
  PyTuple_SetItem(pArgs,1,Py_BuildValue("s",modelPath.c_str()));

  //返回值
  pReturn = PyEval_CallObject(pFunc, pArgs); //调用函数
  Py_DECREF(pFunc);
  //将返回值转换为double类型
  double result;
  PyArg_Parse(pReturn, "d", &result); //d表示转换成double型变量
  //std::cout<<"ebm value: "<<result<<std::endl;
  Py_Finalize();
  return result;
}
// #include "graspit/EGPlanner/energy/contactEnergy.h"
// #include "graspit/robot.h"
// #include "graspit/grasp.h"
// #include "graspit/debug.h"
// #include "graspit/world.h"
// #include "graspit/contact/virtualContact.h"

// double ContactEnergy::energy() const
// {
//   /*
//   this is if we don't want to use pre-specified contacts, but rather the closest points between each link
//   and the object all iterations. Not necessarily needed for contact energy, but useful for GQ energy
//   */

//   if (mContactType == CONTACT_LIVE && mType != "AUTO_GRASP_QUALITY_ENERGY" && mType != "STRICT_AUTO_GRASP_ENERGY")
//   {
//     mHand->getWorld()->findVirtualContacts(mHand, mObject);
//     DBGP("Live contacts computation");
//   }

//   mHand->getGrasp()->collectVirtualContacts();

//   //DBGP("Contact energy computation")
//   //average error per contact
//   VirtualContact *contact;
//   vec3 p, n, cn;
//   double totalError = 0;
//   for (int i = 0; i < mHand->getGrasp()->getNumContacts(); i++)
//   {
//     contact = (VirtualContact *)mHand->getGrasp()->getContact(i);
//     contact->getObjectDistanceAndNormal(mObject, &p, NULL);
//     double dist = p.norm();

//     //this should never happen anymore since we're never inside the object
//     //if ( (-1.0 * p) % n < 0) dist = -dist;

//     //BEST WORKING VERSION, strangely enough
//     totalError += fabs(dist);

//     //let's try this some more
//     //totalError += distanceFunction(dist);
//     //cn = -1.0 * contact->getWorldNormal();

//     //new version
//     cn = contact->getWorldNormal();
//     n = p.normalized();
//     double d = 1 - cn.dot(n);
//     totalError += d * 100.0 / 2.0;
//   }

//   totalError /= mHand->getGrasp()->getNumContacts();

//   //DBGP("Contact energy: " << totalError);
//   return totalError;
// }
