#!/bin/bash
cat > /tmp/doscripts.sh << EOF
#!/bin/bash
cd ~rnovak/github/cpuspeed
git pull
sleep 3
make
cd ~rnovak/github/cpuspeed/results
rm *.csv *.txt *.sh
mkdir valid_results working_scripts
awrapper
for script in script*.sh
do
  bash -x \${script}
done
EOF
# for i in optiplex980 inspiron3185 lr br pi3
# do
#   echo Working on $i
#   ssh ${USER}@$i 'bash -s -x' /tmp/doscripts.sh
# done
bash -x /tmp/doscripts.sh

