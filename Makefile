deps:
	which keytool
	which apksigner
	which docker

my-release-key.keystore:
	read -p "Generate keystore file?" PROCEED
	[ -f my-release-key.keystore ] && cp my-release-key.keystore my-release-key.keystore.$$(date +%s)
	keytool -genkey \
	  -v \
	  -storepass testtest \
	  -keystore my-release-key.keystore \
	  -alias testtest \
	  -keyalg RSA \
	  -keysize 2048 \
	  -validity 10000 \
	  -dname "cn=Test Test, ou=Test, o=Test, c=AU"

versions.txt: clone
	cd Signal-Android && git tag | sort -V | tail -n 30 | grep -v 'v.1.2.4' | grep -v 'v.4.50.1' > ../versions.txt

clone:
	test -d Signal-Android || git clone https://github.com/signalapp/Signal-Android
	cd Signal-Android && git reset --hard
	cd Signal-Android && git checkout main
	cd Signal-Android && git pull

build: deps clone my-release-key.keystore
	test -n "$${VERSION}" || (echo "VERSION is not set, set it to one of the signal tags, eg VERSION=v6.16.1 make build" && exit 1)
	./build.sh "$${VERSION}"

publish:
	test -d $${VERSION} || (echo "No build folder found named $${VERSION}" && exit 1)
	./publish.sh "$${VERSION}"

my-builds: deps versions.txt my-release-key.keystore
	test -n "$${GITHUB_TOKEN}"
	ssh-add -l
	@echo "Going to build these versions:"
	cat versions.txt
	sleep 3
	for v in $$(cat versions.txt); do \
	  VERSION=$${v} make build; \
	  VERSION=$${v} make publish; \
	done



.PHONY: deps build clone quick
