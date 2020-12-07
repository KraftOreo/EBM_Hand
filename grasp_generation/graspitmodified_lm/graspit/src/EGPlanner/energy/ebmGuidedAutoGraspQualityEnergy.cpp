#include "graspit/EGPlanner/energy/ebmguidedAutoGraspEnergy.h"
#include "graspit/robot.h"
#include "graspit/grasp.h"
#include "graspit/debug.h"
#include "graspit/world.h"
#include "graspit/quality/quality.h"
#include "graspit/contact/virtualContact.h"
#include <python3.7/Python.h>

/**
 * @brief This formulation combines virtual contact energy with autograsp energy. In addition, it computes EBM-based energy to access human-like grasping. 
    Virtual contact energy is used to "guide" initial stages of the search and to see if we should even bother computing autograsp quality. 
    Autograsp is a couple of orders of magnitude higher and so should work very well with later stages of the sim ann search.
    EBM-based energy is used to guide human-like grasping generation. This energy is computed by EBM learning model.
    Note that, EBM-based energy is implementation based on python, so we need to write an interface to run python script.
 * @author Jian Liu
 * 
 */
double
EBMGuidedAutoGraspQualityEnergy::energy() const
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
  double virtualError = 0;
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
  }

  totalError /= mHand->getGrasp()->getNumContacts();

  /**
   * @brief EBM-based energy computation. 
   * Ebm enery is negtive and the smaller enery value implys that the generated grasp is more human-like.
   * @author Jian Liu
   */
  double* dofVals;
  mHand->getDOFVals(dofVals);
  double ebmQuality = 0;
  ebmQuality = ebm_pythonInterface(dofVals,mHand->numDOF,mHand->getEBMPath());

  //if more than 2 links are "close" go ahead and compute the true quality
  double volQuality = 0, epsQuality = 0;
  if (closeContacts >= 2) {
    mHand->autoGrasp(false, 1.0);
    //now collect the true contacts;
    mHand->getGrasp()->collectContactgetNumContactss();
    if (mHand->getGrasp()->() >= 4) {
      mHand->getGrasp()->updateWrenchSpaces();
      volQuality = mVolQual->evaluate();
      epsQuality = mEpsQual->evaluate();
      if (epsQuality < 0) { epsQuality = 0; } //QM returns -1 for non-FC grasps
    }

    DBGP("Virtual error " << virtualError << " and " << closeContacts << " close contacts.");
    DBGP("Volume quality: " << volQuality << " Epsilon quality: " << epsQuality);
    DBGP("Human-like quality: " << ebmQuality);
  }

  double q;
  if (volQuality == 0) { q = virtualError; }
  else { q = virtualError - volQuality * 1.0e3 + ebmQuality * 1.0e3; }
  if (volQuality || epsQuality) {DBGP("Final quality: " << q);}

  //DBGP("Final value: " << q << std::endl);
  return q;
}

double
EBMGuidedAutoGraspQualityEnergy::ebm_pythonInterface(double* dofVals, int numDOF, std::string modelPath) const
{
  Py_Initialize();
  PyRun_SimpleString("import sys");
  PyRun_SimpleString("sys.path.append('./')");//python脚本路径, 放在cpp的同一路径下
  PyObject *pModule = NULL;
  PyObject *pFunc = NULL;
  pModule = PyImport_ImportModule("ebmPythonInterface");      //Python文件名
  pFunc = PyObject_GetAttrString(pModule, "dof_ebm"); //Python文件中的函数名
  //创建参数:
  PyObject *pArgs = PyTuple_New(2);                 //函数调用的参数传递均是以元组的形式打包的,2表示参数个数
  PyObject* list_dof = PyList_New(0);

  for (size_t i = 0; i < numDOF; i++){
    PyList_Append( list_dof , Py_BuildValue("d", dofVals[i]));// d表示转换成Python的浮点数
  }

  PyTuple_SetItem(pArgs, 0,  list_dof ); //0--序号
  PyTuple_SetItem(pArgs, 1, Py_BuildValue("s", modelPath)); //1--序号, s表示转换成Python字符串
  //返回值
  PyObject *pReturn = NULL;
  pReturn = PyEval_CallObject(pFunc, pArgs); //调用函数
  //将返回值转换为double类型
  double result;
  PyArg_Parse(pReturn, "d", &result); //d表示转换成double型变量
  Py_Finalize();
}