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

versions: clone
	cd Signal-Android && git tag | sort -V | tail -n 30 | grep -v 'v.1.2.4' | grep -v 'v.4.50.1' | sort > ../latestversions.txt
	ls -d v*/ | tr -d / | sort > folders.txt
	comm -23 latestversions.txt folders.txt > versions.txt
	rm -f latestversions.txt folders.txt

clone:
	test -d Signal-Android || git clone https://github.com/signalapp/Signal-Android
	cd Signal-Android && git reset --hard
	cd Signal-Android && git checkout main
	cd Signal-Android && git pull

v6%: deps clone my-release-key.keystore
	./build.sh $@
	test "$$(md5sum my-release-key.keystore | cut -c 1-3)" = "22e" && ./publish.sh $@  # only publish if we're me

mybuilds: deps versions my-release-key.keystore
	test -n "$${GITHUB_TOKEN}"
	ssh-add -l
	@echo "Going to build these versions:"
	cat versions.txt
	sleep 3
	for v in $$(cat versions.txt); do \
	  make $${v}; \
	done

.PHONY: deps clone versions mybuilds
