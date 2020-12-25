import os, stat, random, transforms3d, math, re, sys, subprocess
from shutil import copyfile
import numpy as np
import argparse
import string
from xml.dom.minidom import parse
from Directions import Directions
#from langevin import sample_langevin

# Add by liujian
# Run_batch_sever
# from itertools import imap

def subprocess_cmd(command):
    process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
    proc_stdout = process.communicate()[0].strip()
    print(proc_stdout)


def anyTrue(predicate, sequence):
    # return True in imap(predicate, sequence)
    for s in sequence:
        if predicate(s):
            return True
    return False


def mkdir(path):
    folder = os.path.exists(path)
    if not folder:
        os.makedirs(path)


def filterFiles(folder, exts, list):
    filenames = os.listdir(folder)
    filenames.sort(key=lambda x:int(x[:-4]))
    for fileName in filenames:
        if os.path.isdir(folder + '/' + fileName):
            filterFiles(folder + '/' + fileName, exts, list)
        elif anyTrue(fileName.endswith, exts):
            list.append(folder + '/' + fileName)


#def dof_ebm(ebm_model, ebm_stepsize, ebm_n_step):
def dof_ebm():
    #init_dof= [0]*20
    #sample_dof = sample_langevin(init_dof, ebm_model, ebm_stepsize, ebm_n_step, intermediate_samples=False)
    # Test
    #sample_dof = [0, 0.76481, 0.1898, 0.13557, 0, 0.43311, 0.029243, 0.020888, 0, 0.15028, 0.047459, 0.033899, 0,
    #                 0.23049, 0.21495, 0.15354, 0, -0.87266, 0, 0.14549]
    sample_dof = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    strdof = [str(i) for i in sample_dof]
    sample_dof = ','.join(strdof)
    sample_dof = ['--robotDOF=', sample_dof, ' ']
    sample_dof = ''.join(sample_dof)

    #print(sample_dof)

    return sample_dof

#Add by Jian Liu
#Note: Using EBM-based grasp planner to generate grasp candidates. 
#      EBM-based grasp planner combines guided auto grasp with EBM learning model.
#      It takes about 173 seconds at a time.
def gen_script_for_each_xml(root_path, robot_xml_path, xml_name, built_binary_path, gen_scripts_path, result_path, model_path=None):
    robot_ori_quat = [1,0,0,0]
    robot_ori_tran = [1000, 0, 0]

    elements = re.split('/', xml_name)
    sub_path = gen_scripts_path + '/' + elements[len(elements) - 1]
    mkdir(root_path + '/' + sub_path)
    # if os.path.exists(sub_path + '/run.sh'):
    #     print('Detected Script: ' + root_path + '/' + sub_path + '/run.sh')
    # else:
    #     print('Generating Script: ' + root_path + '/' + sub_path + '/run.sh')
    if True:
        f = open(root_path + '/' + sub_path + '/run.sh', 'w')
        script = ''
        num_run = 1 # The number of times the algorithm is called
        for j in range(num_run):
            if os.path.exists(root_path + '/' + sub_path + '/' + elements[len(elements)-1] + '_' + str(j)):
                print('Detected Filefold: ' + root_path + '/' + sub_path + '/' + elements[len(elements)-1] + '_' + str(j))
            else:
                mkdir(root_path + '/' + sub_path + '/' + elements[len(elements)-1] + '_' + str(j))

            robot_zrot = math.pi / (j + 1)  # radians
            robot_yrot = robot_zrot
            robot_xrot = robot_zrot
            # print(robot_xrot, robot_yrot, robot_zrot)
            # print('--------------------------------')
            robot_R = transforms3d.taitbryan.euler2mat(robot_zrot, robot_yrot, robot_xrot)  # rotations
            robot_coor_T_R = np.matmul(robot_R, robot_ori_tran)
            robot_quat2mat = transforms3d.quaternions.quat2mat(robot_ori_quat)
            robot_quat2mat_R = np.matmul(robot_R, robot_quat2mat)
            robot_mat2quat = transforms3d.quaternions.mat2quat(robot_quat2mat_R)

            #script += root_path + '/' + built_binary_path + ' '
            script += built_binary_path + ' '
            script += '--bodyFile=' + xml_name + ' '
            script += '--bodyRot=1,0,0,0 '
            script += '--bodyTrans=0,0,0 '
            script += '--robotFile=' + root_path + '/' + robot_xml_path + ' '
            script += '--robotRot=' + str(robot_mat2quat[0]) + ',' + str(robot_mat2quat[1]) + ',' + str(robot_mat2quat[2]) + ',' + str(robot_mat2quat[3]) + ' '
            script += '--robotTrans=' + str(robot_coor_T_R[0]) + ',' + str(robot_coor_T_R[1]) + ',' + str(robot_coor_T_R[2]) + ' '
            # Run a interface to compute a initial human hand by EBM
            script += dof_ebm()
            script += '--resultFile=' + root_path + '/' + sub_path + '/' + elements[len(elements)-1] + '_' + str(j) + '/ '
                
            script += "--modelPath=" + model_path + '\n'
            script += 'cp -r ' + root_path + '/' + sub_path + '/' + elements[len(elements)-1] + '_' + str(j) + ' '
            script += root_path + '/' + result_path + '\n\n'
        f.write(script)
        f.close()

    #Permission
    os.chmod(root_path + '/' + sub_path + '/run.sh', stat.S_IRWXO+stat.S_IRWXG+stat.S_IRWXU)
    os.system(root_path + '/' + sub_path + '/run.sh')


def gen_script_for_each_xml_local(root_path, robot_xml_path, xml_name, built_binary_path, gen_scripts_path, result_path, model_path=None):
    robot_ori_quat = [1, 0, 0, 0]
    # robot_ori_tran = [1000, 0, 0]
    '''
        Randomly generating directions. when res=5, 98 directions are generated.
    '''
    dirs = Directions(res=2, dim=3).dirs
    robot_ori_trans = np.array(dirs,dtype=np.float64) * 1000
    
    '''
    '''
    elements = re.split('/', xml_name)
    sub_path = gen_scripts_path + '/' + elements[len(elements) - 1]
    mkdir(root_path + '/' + sub_path)
    if os.path.exists(sub_path + '/run.sh'):
        print('Detected Script: ' + root_path + '/' + sub_path + '/run.sh')
    else:
        print('Generating Script: ' + root_path + '/' + sub_path + '/run.sh')

        f = open(root_path + '/' + sub_path + '/run.sh', 'w')

        script = ''
        sub_xmlFile = []
        for i in range(robot_ori_trans.shape[0]):
            robot_ori_tran = robot_ori_trans[i, :]
            for j in range(2):
                for k in range(2):
                    for m in range(2):
                        if os.path.exists(
                                root_path + '/' + sub_path + '/' + elements[len(elements) - 1] + "_" + str(i) + '_' + str(j) + '_' + str(
                                        k) + '_' + str(m)):
                            print('Detected Filefold: ' + root_path + '/' + sub_path + '/' + elements[
                                len(elements) - 1] + '_' + str(j) + '_' + str(k) + '_' + str(m))
                        else:
                            sub_file = root_path + '/' + sub_path + '/' + elements[len(elements) - 1] + "_" + str(i) + '_' + str(j) + '_' + str(
                                k) + '_' + str(m)
                            sub_xmlFile.append(sub_file)
                            mkdir(sub_file)

                        robot_zrot = math.pi / (j + 1)  # radians
                        robot_yrot = math.pi / (k + 1)
                        robot_xrot = math.pi / (m + 1)
                        # print(robot_xrot, robot_yrot, robot_zrot)
                        # print('--------------------------------')
                        robot_R = transforms3d.taitbryan.euler2mat(robot_zrot, robot_yrot, robot_xrot)  # rotations
                        robot_coor_T_R = np.matmul(robot_R, robot_ori_tran)
                        robot_quat2mat = transforms3d.quaternions.quat2mat(robot_ori_quat)
                        robot_quat2mat_R = np.matmul(robot_R, robot_quat2mat)
                        robot_mat2quat = transforms3d.quaternions.mat2quat(robot_quat2mat_R)

                        # Note: random initial human hand generated by EBM (20dof)
                        script += root_path + '/' + built_binary_path + ' '
                        script += '--bodyFile=' + xml_name + ' '
                        script += '--bodyRot=1,0,0,0 '
                        script += '--bodyTrans=0,0,0 '
                        script += '--robotFile=' + root_path + '/' + robot_xml_path + ' '
                        script += '--robotRot=' + str(robot_mat2quat[0]) + ',' + str(robot_mat2quat[1]) + ',' + str(
                            robot_mat2quat[2]) + ',' + str(robot_mat2quat[3]) + ' '
                        script += '--robotTrans=' + str(robot_coor_T_R[0]) + ',' + str(robot_coor_T_R[1]) + ',' + str(
                            robot_coor_T_R[2]) + ' '
                        # Run a interface to compute a initial human hand by EBM
                        script += dof_ebm()
                        #script += '--robotDOF=0,0,0,0 '
                        script += '--resultFile=' + root_path + '/' + sub_path + '/' + elements[
                            len(elements) - 1] + "_" + str(i) + '_' + str(j) + '_' + str(k) + '_' + str(m) + '/\n'
                        
                        script += '--modelPath=' + model_path
                        script += 'cp -r ' + root_path + '/' + sub_path + '/' + elements[len(elements) - 1] + "_" + str(i) + '_' + str(
                            j) + '_' + str(k) + '_' + str(m) + ' '
                        script += root_path + '/' + result_path + '\n\n'

        f.write(script)
        f.close()

    #Permission
    os.chmod(root_path + '/' + sub_path + '/run.sh', stat.S_IRWXO+stat.S_IRWXG+stat.S_IRWXU)

    #Generate grasp candidate for each initial human hand
    #print('cd ' + root_path + '/' + sub_path + '; ./run.sh;')
    # subprocess_cmd('cd ' + root_path + '/' + sub_path + '; ./run.sh;')
    os.system(root_path + '/' + sub_path + '/run.sh')
    #Read dof from xml of every grasp human hand
   # dofValues, quat, trans = read_dof_grasp(sub_xmlFile)

    #Run EBM model to evaluate quality metric


def read_dof_XML(xml_name):
    domTree = parse(xml_name)
    rootNode = domTree.documentElement
    robot = rootNode.getElementsByTagName("robot")
    dofValues = robot.getElementByTagName("dofValues")[0]
    transform = robot.getElementByTagName("dofValues")[0]

    fullTransform = transform.getElementByTagName("fullTransform")[0]
    #Test:
    print(dofValues.nodeName, ':', dofValues.childNodes[0].data)
    print(fullTransform.nodeName,':',fullTransform.childNodes[0].data)

    dofValues = dofValues.childNodes[0].data
    dofValues = dofValues.split(' ')
    dofValues = [string.atof(dof) for dof in dofValues]

    fullTransform = fullTransform.childNodes[0].data

    quat = fullTransform[1:fullTransform.find(')')-1]
    quat = quat.split(' ')
    quat = [string.atof(q) for q in quat]

    trans = fullTransform[fullTransform.find('[')+1:-2]
    trans = trans.split(' ')
    trans = [string.atof(t) for t in trans]

    return dofValues, quat, trans


def read_dof_grasp(sub_xmlFile):
    for file in sub_xmlFile:
        for i in range(20):
            xml_name = file+'/grasp'+str(i)+'.xml'
            #test
            print(xml_name)
            dofValues, quat, trans = read_dof_XML(xml_name)



def gen_all_scripts(testRun, root_path, object_xml_path, robot_xml_path, built_binary_path, gen_scripts_path, final_result_path, model_path=None):
    if not os.path.exists(root_path + '/' + gen_scripts_path):
        os.mkdir(root_path + '/' + gen_scripts_path)

    if not os.path.exists(root_path + '/' + final_result_path):
        os.mkdir(root_path + '/' + final_result_path)

    xml_file_list = []
    filterFiles(root_path + '/' + object_xml_path, '.xml', xml_file_list)
    #print(xml_file_list)
    #print(sorted(xml_file_list))
    #exit(1)

    #gen_script_for_each_xml(root_path, robot_xml_path, xml_file_list[0], built_binary_path, gen_scripts_path, final_result_path, model_path=model_path)

    for i in range(len(xml_file_list)):
        gen_script_for_each_xml(root_path, robot_xml_path, xml_file_list[i], built_binary_path, gen_scripts_path, final_result_path, model_path=model_path)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=os.path.basename(__file__))
    parser.add_argument('--testRun', default=False,action='store_true')
    parser.add_argument('--root_path', default=os.path.dirname(os.path.realpath(__file__)))
    parser.add_argument('--object_xml_path', default='../vr_shapes')
    parser.add_argument('--robot_xml_path', default='graspitmodified_lm/graspit/models/robots/HumanHand/HumanHand20DOF.xml')
    parser.add_argument('--built_binary_path', default='~/graspitmodified-build/graspit/graspit_cmdline')
    parser.add_argument('--gen_scripts_path', default='batch')
    parser.add_argument('--final_result_path', default='output')
    parser.add_argument('--model_path', default='/root/WorkSpace/EBM_Result/models/model_21:22:48-Nov-30-2020/model_0.pkl')
    #parser.add_argument('--model_path', default='/home/liujian/WorkSpace/EBM_Result/models/model_21:22:48-Nov-30-2020/model_0.pkl')
    args = parser.parse_args()
    gen_all_scripts(args.testRun,
                    args.root_path,
                    args.object_xml_path,
                    args.robot_xml_path,
                    args.built_binary_path,
                    args.gen_scripts_path,
                    args.final_result_path,
                    args.model_path
                    )
