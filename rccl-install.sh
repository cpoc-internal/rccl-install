sudo sh -c 'echo 0 > /proc/sys/kernel/numa_balancing'
rocm-smi --setperfdeterminism 1900
sudo apt  install docker.io -y
sudo apt install cmake -y
sudo apt install mpich -y
git clone --recursive https://github.com/ROCm/rccl.git
cd rccl
./install.sh -d
mkdir build
#cd build
#cmake ..
#make -j 8
sleep 5
cd 
echo "cloning rccl test"
git clone https://github.com/ROCm/rccl-tests.git
cd rccl-tests
./install.sh
./build/all_reduce_perf -b 8 -e 10g -f 2 -g 8

echo "done"
