#!/bin/bash
#生成日志数据追加到指定文件
#2020-12-11 15:39:25,842[[ACTIVE] ExecuteThread: '1' for queue: 'weblogic.kernel.Default (self-tuning)'] INFO :

if [ $# != 4 ]; then
    echo '输入参数不合法,参数格式: -n 执行次数 -file 目标文件'
    exit;
fi

var1=$1
var2=$2
var3=$3
var4=$4

messageFile="./message.txt"
if [ ! -f $messageFile ]; then
    echo "缺少message.txt资源文件"
    exit
fi

#生成指定范围随机数
function rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(date +%s%N)
    echo $(($num%$max+$min))
}

nullPointerExceptionMessage="java.lang.NullPointerException: null
        at com.tingyun.shiro.auth.JwtRealm.doGetAuthenticationInfo(JwtRealm.java:88)
        at org.apache.shiro.realm.AuthenticatingRealm.getAuthenticationInfo(AuthenticatingRealm.java:571)
        at org.apache.shiro.authc.pam.ModularRealmAuthenticator.doMultiRealmAuthentication(ModularRealmAuthenticator.java:219)
        at org.apache.shiro.authc.pam.ModularRealmAuthenticator.doAuthenticate(ModularRealmAuthenticator.java:269)
        at org.apache.shiro.authc.AbstractAuthenticator.authenticate(AbstractAuthenticator.java:198)
        at org.apache.shiro.mgt.AuthenticatingSecurityManager.authenticate(AuthenticatingSecurityManager.java:106)
        at org.apache.shiro.mgt.DefaultSecurityManager.login(DefaultSecurityManager.java:275)
        at org.apache.shiro.subject.support.DelegatingSubject.login(DelegatingSubject.java:260)
        at com.tingyun.shiro.auth.JwtFilter.onAccessDenied(JwtFilter.java:70)"

#获取核心数
core=$(cat /proc/cpuinfo| grep "cpu cores" | uniq | cut -c 13-13)

levels=(INFO INFO INFO INFO DEBUG DEBUG DEBUG WARN WARN ERROR)
length=${#levels[*]}

while read line
do
    messageArr[i++]=$line
done <$messageFile
messageLength=${#messageArr[@]}

for (( i = 0; i < $var2; i++ )); do
    #日志信息
    message=${messageArr[$(rand 0 $messageLength-1)]}
    #日志级别
    level=${levels[$(rand 0 9)]}
    if [ $level = "ERROR" ]; then
        message=$nullPointerExceptionMessage
    fi
    #时间
    # now=$(date -d "-$[RANDOM%365] day -$[RANDOM%24] hour" "+%Y-%m-%d %H:%M:%S")
    now=$(date "+%Y-%m-%d %H:%M:%S")
    #线程号
    thread=$(rand 1 $core)
    head="[[ACTIVE] ExecuteThread: '$thread' for queue: 'weblogic.kernel.Default (self-tuning)']"

    echo "$now $head $level: $message" >> $var4
    sleep 1s
done

exit;


