all:	pycrypto/build

# Fedora 12 uses GMP 4.3, but pycrypto requires 5.* or later to get
# to get mpz_powm_sec. Use --without-gmp to avoid the dependency,
# assuming that performance is not a core requirement for this
# deployment.

pycrypto/build:
	( cd pycrypto && ./configure --without-gmp )
	( cd pycrypto && python setup.py build )
