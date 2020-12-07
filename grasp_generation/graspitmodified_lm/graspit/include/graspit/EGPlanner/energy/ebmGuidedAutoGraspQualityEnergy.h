#ifndef _ebmguidedautograspenergy_h_
#define _ebmguidedautograspenergy_h_

#include "graspit/EGPlanner/energy/searchEnergy.h"
#include <string.h>

/**
 * @brief EBM-based energy
 * @author Jian Liu
 * 
 */
class EBMGuidedAutoGraspQualityEnergy: public SearchEnergy
{
  public:
    double energy() const;
  protected: 
  /**
   * @brief An interface to run EBM model.
   * 
   * @param dofVals DOF of hand
   * @param numDOF number of DOF
   * @return double ebm energy value that is used to predict human-like grasping.
   */
    double ebm_pythonInterface(double* dofVals, int numDOF,std::string modelPath) const;
};


#endif
