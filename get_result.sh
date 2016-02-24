crushweight=0
target_crush_weight=3.59
step=0.2
until [ $(echo "$crushweight >= $target_crush_weight" |bc) -eq 1 ]
do
  last_weight=$crushweight
  crushweight=$(echo "$crushweight+$step" | bc)
  if [ $(echo "$crushweight > $target_crush_weight" |bc) -eq 1 ]
  then
     crushweight=$target_crush_weight
  fi
  diff=`python diff.py capadd_cw_${last_weight}_ow_1_mapping capadd_cw_${crushweight}_ow_1_mapping`
  echo "$last_weight $crushweight $diff" >>result.txt
  echo "$last_weight $crushweight $diff" 
done
