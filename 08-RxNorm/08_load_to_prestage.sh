#!/bin/bash
###############################################################################
#
#   OMOP - Cloud Research Lab
# 
#   Observational Medical Outcomes Partnership
#   (c)2009-2011 Foundation for the National Institutes of Health (FNIH)
# 
#   Licensed under the Apache License, Version 2.0 (the "License"); you may not
#   use this file except in compliance with the License. You may obtain a copy
#   of the License at http://omop.fnih.org/publiclicense.
# 
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#   WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. Any
#   redistributions of this work or any derivative work or modification based on
#   this work should be accompanied by the following source attribution: "This
#   work is based on work by the Observational Medical Outcomes Partnership
#   (OMOP) and used under license from the FNIH at
#   http://omop.fnih.org/publiclicense.
# 
#   Any scientific publication that is based on this work should include a
#   reference to http://omop.fnih.org.
# 
#   Date:       2011/06/1
#
#   Script that perform loading of RxNorm.
#   To load RxNorm data unpacked to folder rxnormdata
#   call  
#   bash load_rxnorm.sh rxnormdata rxnorm/OmoP10
# 
############################################################################### 
ROOT_DIR=$1
CONNECTION_STRING=$2

if [ -f ${ROOT_DIR}/RXNATOMARCHIVE.RRF1 ]; then
    echo "EXIT" | sqlplus ${CONNECTION_STRING} @${ROOT_DIR}/../rxnorm/scripts/oracle/RxNormDDL.sql

    sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/../rxnorm/scripts/oracle/RXNATOMARCHIVE.ctl data=${ROOT_DIR}/RXNATOMARCHIVE.RRF
    sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/../rxnorm/scripts/oracle/RXNCONSO.ctl data=${ROOT_DIR}/RXNCONSO.RRF
    sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/../rxnorm/scripts/oracle/RXNDOC.ctl data=${ROOT_DIR}/RXNDOC.RRF
    sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/../rxnorm/scripts/oracle/RXNREL.ctl data=${ROOT_DIR}/RXNREL.RRF
    sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/../rxnorm/scripts/oracle/RXNSAB.ctl data=${ROOT_DIR}/RXNSAB.RRF
    sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/../rxnorm/scripts/oracle/RXNSAT.ctl data=${ROOT_DIR}/RXNSAT.RRF
    sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/../rxnorm/scripts/oracle/RXNSTY.ctl data=${ROOT_DIR}/RXNSTY.RRF
else
    if [ -f ${ROOT_DIR}/scripts/RxNormDDL.sql ]; then
        echo "EXIT" | sqlplus ${CONNECTION_STRING} @${ROOT_DIR}/scripts/RxNormDDL.sql
    
        sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/scripts/RXNATOMARCHIVE.ctl data=${ROOT_DIR}/rrf/RXNATOMARCHIVE.RRF
        sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/scripts/RXNCONSO.ctl data=${ROOT_DIR}/rrf/RXNCONSO.RRF
        sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/scripts/RXNDOC.ctl data=${ROOT_DIR}/rrf/RXNDOC.RRF
        sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/scripts/RXNREL.ctl data=${ROOT_DIR}/rrf/RXNREL.RRF
        sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/scripts/RXNSAB.ctl data=${ROOT_DIR}/rrf/RXNSAB.RRF
        sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/scripts/RXNSAT.ctl data=${ROOT_DIR}/rrf/RXNSAT.RRF
        sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/scripts/RXNSTY.ctl data=${ROOT_DIR}/rrf/RXNSTY.RRF
        sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/scripts/RXNCUICHANGES.ctl data=${ROOT_DIR}/rrf/RXNCUICHANGES.RRF
        sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/scripts/RXNCUI.ctl data=${ROOT_DIR}/rrf/RXNCUI.RRF
    else
        echo "EXIT" | sqlplus ${CONNECTION_STRING} @${ROOT_DIR}/scripts/oracle/RxNormDDL.sql
    
        sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/scripts/oracle/RXNATOMARCHIVE.ctl data=${ROOT_DIR}/rrf/RXNATOMARCHIVE.RRF
        sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/scripts/oracle/RXNCONSO.ctl data=${ROOT_DIR}/rrf/RXNCONSO.RRF
        sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/scripts/oracle/RXNDOC.ctl data=${ROOT_DIR}/rrf/RXNDOC.RRF
        sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/scripts/oracle/RXNREL.ctl data=${ROOT_DIR}/rrf/RXNREL.RRF
        sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/scripts/oracle/RXNSAB.ctl data=${ROOT_DIR}/rrf/RXNSAB.RRF
        sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/scripts/oracle/RXNSAT.ctl data=${ROOT_DIR}/rrf/RXNSAT.RRF
        sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/scripts/oracle/RXNSTY.ctl data=${ROOT_DIR}/rrf/RXNSTY.RRF
        sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/scripts/oracle/RXNCUICHANGES.ctl data=${ROOT_DIR}/rrf/RXNCUICHANGES.RRF
        sqlldr ${CONNECTION_STRING} control=${ROOT_DIR}/scripts/oracle/RXNCUI.ctl data=${ROOT_DIR}/rrf/RXNCUI.RRF
    fi
fi

