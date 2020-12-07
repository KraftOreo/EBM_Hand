#!/bin/bash
if [ ! -d "../graspitmodified-build" ]; then
  mkdir ../graspitmodified-build
fi
cd ../graspitmodified-build

if [ ! -d "SoQt" ]; then
  mkdir SoQt
fi
cd SoQt

../../graspitmodified_lm/SoQt-1.5.0/configure --with-coin=../coin/install-custom --with-qt=/usr/ --prefix=$(pwd)/../coin/install-custom
make install