#!/bin/bash
cat > /tmp/doscripts.sh << EOF
#!/bin/bash
cd github/cpuspeed
git pull
sleep 3
make
cd results
git rm * verified_results/* working_scripts/*
mkdir verified_results working_scripts
awrapper
for script in script*.sh
do
  bash -x \${script}
done
EOF
for i in optiplex980 inspiron3185 lr br pi3
do
  echo Working on $i
  ssh ${USER}@$i 'bash -s -x' /tmp/doscripts.sh
done
