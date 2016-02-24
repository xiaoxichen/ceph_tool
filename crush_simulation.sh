
num_osds=600
osds_to_add=60
osds_per_host=20
hosts_per_rack=10
original_map="/root/original_map_"$num_osds
cap_add_map="/root/original_map_"$((num_osds + osds_to_add))
target_crush_weight=3.59
pool_id=0
num_pg=32768

crushweight=0
step=0.2
cp template_600 $original_map
for i in `seq 0 $((num_osds - 1))`
do
  echo $i
  crushtool -i ${original_map} --reweight-item $i $target_crush_weight -o ${original_map}_new
  cp ${original_map}_new ${original_map}
done
crushtool -i ${original_map} --test --pool-id ${pool_id} --x ${num_pg} --show-mappings --num-rep 3 >original_mapping
#add new osds

cp template_660 $cap_add_map
for i in `seq 0 $((num_osds - 1))`
do
  echo $i
  crushtool -i ${cap_add_map} --reweight-item $i $target_crush_weight -o ${cap_add_map}_new
  cp ${cap_add_map}_new ${cap_add_map}
done
for i in `seq ${num_osds} $((num_osds + osds_to_add - 1))`
do
  echo $i
  crushtool -i ${cap_add_map} --reweight-item $i 0 -o ${cap_add_map}_new
  cp ${cap_add_map}_new ${cap_add_map}
done
crushtool -i ${cap_add_map} --test --pool-id ${pool_id} --x ${num_pg} --show-mappings --num-rep 3 >capadd_cw_0_ow_1_mapping
#scale weight
crushweight=0
until [ $(echo "$crushweight >= $target_crush_weight" |bc) -eq 1 ]
do
  crushweight=$(echo "$crushweight+$step" | bc)
  if [ $(echo "$crushweight > $target_crush_weight" |bc) -eq 1 ]
  then
     crushweight=$target_crush_weight
  fi
  echo $crushweight
  for i in `seq ${num_osds} $((num_osds + osds_to_add - 1))`
  do
    crushtool -i ${cap_add_map} --reweight-item $i $crushweight -o ${cap_add_map}_new
    cp ${cap_add_map}_new ${cap_add_map}
  done
  crushtool -i ${cap_add_map} --test --pool-id ${pool_id} --x ${num_pg} --show-mappings --num-rep 3 >capadd_cw_${crushweight}_ow_1_mapping
done
