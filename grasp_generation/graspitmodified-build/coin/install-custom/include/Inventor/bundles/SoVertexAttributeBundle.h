#ifndef COIN_VERTEXATTRIBUTEBUNDLE_H
#define COIN_VERTEXATTRIBUTEBUNDLE_H

/**************************************************************************\
 *
 *  This file is part of the Coin 3D visualization library.
 *  Copyright (C) by Kongsberg Oil & Gas Technologies.
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License
 *  ("GPL") version 2 as published by the Free Software Foundation.
 *  See the file LICENSE.GPL at the root directory of this source
 *  distribution for additional information about the GNU GPL.
 *
 *  For using Coin with software that can not be combined with the GNU
 *  GPL, and for taking advantage of the additional benefits of our
 *  support services, please contact Kongsberg Oil & Gas Technologies
 *  about acquiring a Coin Professional Edition License.
 *
 *  See http://www.coin3d.org/ for more information.
 *
 *  Kongsberg Oil & Gas Technologies, Bygdoy Alle 5, 0257 Oslo, NORWAY.
 *  http://www.sim.no/  sales@sim.no  coin-support@coin3d.org
 *
\**************************************************************************/

#include <Inventor/bundles/SoBundle.h>
#include <Inventor/elements/SoGLVertexAttributeElement.h>

class SoVertexAttributeBundleP;

class COIN_DLL_API SoVertexAttributeBundle : public SoBundle {
public:
  SoVertexAttributeBundle(SoAction * action, SbBool forrendering);
  ~SoVertexAttributeBundle();

  void send(int index) const;
  SbBool doAttributes(void) const;
  
private:
  const SoVertexAttributeElement * elem;
  const SoGLVertexAttributeElement * glelem;
};


#endif // !COIN_VERTEXATTRIBUTEBUNDLE_H