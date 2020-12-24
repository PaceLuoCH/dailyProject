#!/bin/bash
#生成json格式日志数据追加到指定文件
#{"timeMillis":1538900322132,"thread":"main","threadPriority":"5","level":"info","loggerName":"","message": "","data":{"responseBody": {"datetime": "", "status": 1, "ip":"127.0.0.1"}}}

if [ $# != 4 ]; then
    echo '输入参数不合法,参数格式: -size 指定大小（MB） -file 目标文件'
    exit;
fi

var1=$1
size=$2
var3=$3
targetFile=$4

ipFile="./ip.txt"
if [ ! -f $ipFile ]; then
    echo "缺少ip.txt资源文件"
    exit
fi

#生成指定范围随机数
function rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(date +%s%N)
    echo $(($num%$max+$min))
}

thread="main"

threadPriority="5"

levels=(INFO INFO INFO INFO DEBUG DEBUG DEBUG WARN WARN ERROR)

loggerName="logback.LogbackDemo"

statusList=(0 1 2)

while read line
do
  ips[i++]=$line
done <$ipFile

for (( i = 0; i < 1; )); do
  if [ ! -f $targetFile ]; then
        $(touch $targetFile)
  fi

  nowSize=$(du -m $targetFile | grep -o "[0-9]*")
  if [ $nowSize -gt $size ]; then
      suffix=${targetFile##*.}
      file=${targetFile%.*}
      targetFile="$file-cp.$suffix"
  fi

  level=${levels[$(rand 0 ${#levels[@]})-1]}
  if [ $level = "ERROR" ]; then
      echo "{\"timeMillis\": $timeMillis, \"thread\": \"$thread\", \"threadPriority\": \"$threadPriority\", \"level\": \"$level\", \"loggerName\": \"$loggerName\", \"message\": \"com.tingyun.shiro.auth.JwtRealm - 根据Token 从redis获取Account时失败: java.lang.NullPointerException: null\"}" >> $targetFile
      continue
  fi

  current=$(date "+%Y-%m-%d %H:%M:%S")
  timeStamp=$(date -d "$current" +%s)
  #时间戳
  timeMillis=$((timeStamp*1000))
  status=${statusList[$(rand 0 ${#statusList[@]})-1]}
  ip=${ips[$(rand 0 ${#ips[@]})-1]}

  echo "{\"timeMillis\": $timeMillis, \"thread\": \"$thread\", \"threadPriority\": \"$threadPriority\", \"level\": \"$level\", \"loggerName\": \"$loggerName\", \"data\":{\"responseBody\": {\"datetime\": \"$current\", \"status\": $status, \"ip\": \"$ip\"}}}" >> $targetFile
  sleep 1s
done

exit

