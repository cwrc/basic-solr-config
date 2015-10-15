Solr Multi-core setup
--

Create 2 directory within the SOLR_HOME directory, for example:

* solr_core_fedora
** the config for the Fedora Commons Solr index
** add the "conf" directory from the root or the repository (note, not adding to this directory because easier to keep in sync with the original Islandora repository that this repo has forked).
** update solrconfig.xml Solr core config to reflect multicore directory :  <dataDir> (for the current multicore commenting out <dataDir> so that the detault is used
* update FedoraGSearch config to reflect multicore directory: "index.properties" - fgsindex.indexDir

* solr_core_drupal
** the config for the Drupal specific Solr index

The Solr.xml contains the overarching Solr config (e.g. defines the Solr cores)


