SSLTESTS_SRC_DIR = $(SSLTESTS_DIR)/src
SSLTESTS_MAIN_CLASS = Main
SSLTESTS_RUN_TARGET := $(shell if [ 1 = "$(TEST_PKCS11_FIPS)" ] ; then echo "ssl-tests-run-nss" ; else echo "ssl-tests-run-jks" ; fi )
SSLTESTS_DH_KEY_PARAM = $(shell if [ 1 = "$(SET_DH_KEY_SIZE_2048)" ] ; then printf '%s' '-Djdk.tls.ephemeralDHKeySize=2048' ; fi )
SSLTESTS_ONLY_SSL_DEFAULTS_PARAM = $(shell if [ 1 = "$(SSLTESTS_ONLY_SSL_DEFAULTS)" ] ; then  printf '%s' '-Dssltests.onlyssldefaults=1' ; fi )

.PHONY: ssl-tests ssl-tests-clean ssl-tests-build ssl-tests-run

ssl-tests: ssl-tests-run

ssl-tests-clean:
	rm -rf $(SSLTESTS_CLASSES_DIR)

ssl-tests-build: $(SSLTESTS_CLASSES_DIR)

ssl-tests-run-jks: $(SSLTESTS_CLASSES_DIR) $(KEYSTORE_JKS) $(TRUSTSTORE_JKS)
	$(JAVA) -cp $< \
	-Djavax.net.ssl.keyStore=$(KEYSTORE_JKS) \
	-Djavax.net.ssl.keyStorePassword=$(KEYSTORE_PASSWORD) \
	-Djavax.net.ssl.trustStore=$(TRUSTSTORE_JKS) \
	-Djavax.net.ssl.trustStorePassword=$(TRUSTSTORE_PASSWORD) \
	$(SSLTESTS_DH_KEY_PARAM) \
	$(SSLTESTS_ONLY_SSL_DEFAULTS_PARAM) \
	$(SSLTESTS_CUSTOM_JVM_PARAMS) \
	$(SSLTESTS_MAIN_CLASS)

ssl-tests-run-nss: $(SSLTESTS_CLASSES_DIR) $(JAVA_PKCS11_FIPS_SECURITY_CFG)
	$(JAVA) -cp $< \
	-Djava.security.properties=="$(JAVA_PKCS11_FIPS_SECURITY_CFG)" \
	$(SSLTESTS_DH_KEY_PARAM) \
	$(JAVA_PKCS11_FIPS_PARAMS) \
	$(SSLTESTS_ONLY_SSL_DEFAULTS_PARAM) \
	$(SSLTESTS_CUSTOM_JVM_PARAMS) \
	$(SSLTESTS_MAIN_CLASS)

ssl-tests-run: $(SSLTESTS_RUN_TARGET)

$(SSLTESTS_CLASSES_DIR): $(SSLTESTS_SRC_DIR)
	mkdir -p $@
	$(JAVAC) -d $@ $</*