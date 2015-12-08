## Solr 5.3.1 install on Cent OS ##

References:
* https://cwiki.apache.org/confluence/display/solr/Taking+Solr+to+Production
* http://www.shayanderson.com/linux/how-to-install-apache-solr-5-1-on-centos-6.htm
* http://yonik.com/solr-tutorial/

Install:
* use the _install_solr_service.sh_ script with the default parameters
* modify the _/var/solr/sor.in.sh_ file to set the JAVA_HOME variable

Create a Solr Core:
* create "fedora_apachesolr" core
```
sudo -u solr /opt/solr/bin/solr create -c name_of_solr_core 
```

* note:  use "sudo -u solr" otherwise wrong file permisions


Start Solr:
*  sudo service solr start

Enable near realtime searching
* edit the core specific configuration to enable _autoSoftcommit_so that index changes are visible in the search earlier (i.e. before the changes are recorded in storage) - see solrconfig.xml for more details
**   _conf/solrcore.properties_ overrides variables in the solrconfig.xml file
```
    #conf/solrcore.properties
    solr.autoCommit.maxTime=15000
    solr.autoSoftCommit.maxTime=200
```

Set logging level
* /var/solr/log4j.properties
* https://cwiki.apache.org/confluence/display/solr/Configuring+Logging
* to reduce the default log information
```
log4j.rootLogger=WARN, file
log4j.appender.file.MaxFileSize=100MB
```

Changes to solrconfig.xml necessary from the default 5.3.1
* prevent the automatic conversion of _schema.xml_ into the managed-schema
* disable dynamic schema REST APIs
** comment out
*** <schemaFactory class="ManagedIndexSchemaFactory">
** add
*** <schemaFactory class="ClassicIndexSchemaFactory"/>
** comment out
*** <processor class="solr.AddSchemaFieldsUpdateProcessorFactory">

* Reference:
** https://cwiki.apache.org/confluence/display/solr/Schemaless+Mode
** https://github.com/cwrc/basic-solr-config/commit/d0dfd482a0c478f87324bc0a21919a620dc39771
** https://issues.apache.org/jira/browse/SOLR-7234


Changes to the Solr 3.5 schema.xml necessary for usage in Solr 5.3.1
* removal of depricated features and addition of newly added - many changes represented with the following GitHup commit
** https://github.com/cwrc/basic-solr-config/commit/d0dfd482a0c478f87324bc0a21919a620dc39771

## Fedora Generic Search 2.8 for use with Solr 5.3.1 install on Cent OS ##

* References:
** https://groups.google.com/forum/#!topic/islandora-dev/LK5lKi_XP2c

* download
** http://sourceforge.net/projects/fedora-commons/files/services/3.7/fedoragsearch-2.8.zip

* copy over _fgsconfigFinal_ from the previous version

* update config to use the SolrRemote operationsImpl - index/FgsIndex/index.properties
```
fgsindex.operationsImpl = dk.defxws.fgssolrremote.OperationsImpl
fgsindex.indexBase    = http://localhost:8983/solr/fedora_apachesolr
```

* copy of the logging configuration -  log4j.xml

* add a unique client identifier if you want to run multiple version of the GSearch client - index/FgsIndex/index.properties
** client.id                   = fedoragsearch-2.8-0

