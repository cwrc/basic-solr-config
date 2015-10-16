This repo will holds a basic solr config, schema and xslt to use as a starting point for future projects.

It is now dependent on the [discoverygarden GSearch extensions](https://github.com/discoverygarden/dgi_gsearch_extensions)--which includes the Joda time library.

If one wishes to index Drupal content and users, one might process the `conf/data-import-config.xml.erb` into `conf/data-import-config.xml`. It takes three parameters:
* `drupal_dbname`
* `drupal_db_username`
* `drupal_db_password`
*
__

Assumption: start with the Islandora Solr and FedoraGSearch setup from 2013. These config files represent what changes from the default setup of Islandora.

As of 2014-04-09 install location - 

FedoraGSearch
* location to add config: {$TOMCAT_HOME}/webapps/fedoragsearch/WEB-INF/classes/fgsconfigFinal/index/FgsIndex/
* includes: index.properties, foxmlToSolr.xslt, islandora_transforms
* some files contain hardcoded directories - be carful if moving from the Tomcat from the default location

Apache Solr
* location to add config: {$FEDORA_HOME}/solr/conf/
* includes: conf              


In a Multi-Core setup of Apache Solr, the configuration file location changes. For the Fedora Solr core, the see the multicore directory for details.
