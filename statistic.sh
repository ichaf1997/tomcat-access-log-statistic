#!/bin/bash

# Version 0.2
# By Gopppog 
# 2021.01.06 

# 使用方法 $0 timestamp [options]
# 按年统计 $0 2018,2019,2020 --method=GET
# 按月统计 $0 2020-06,2020-07,2020-08 --method=POST
# 按指定日期统计 $0 2020-06-09,2020-07-01 [ --method=ALL [缺省值] ]

# 访问日志存放目录
logs_dir=/tmp/logs
# 过滤出访问日志文件名的正则表达式
common_pattern=rmis_access_log.*.txt
# 统计结果输出的文件
output_file=/tmp/statistics

# 按时间戳查找符合匹配的日志文件
function find_matched_files(){
    key_words=$(echo $1 | sed 's#,#|#g')
    matched_files=$(ls $logs_dir/$common_pattern|egrep -E "$key_words")
    echo $matched_files
}

# 统计结果输出函数,将统计所得字典resources输出到变量output_file指定的文件
function save_dict(){
    save_file=$output_file-${var2:9}
    [ ! -d $(dirname $save_file) ] && mkdir -p $(dirname $save_file)
    [ -f $save_file ] && rm -rf $save_file 
    touch $save_file
    echo "# Start Time: $(date +%Y%m%d\ %H%M%S)" >> $save_file
    echo "# --- Statistic Info ---" >> $save_file
    echo "# Method: ${var2:9}" >> $save_file
    echo "# Statistic Range of Time: $var1" >> $save_file
    for key in ${!resources[*]};
    do
        echo ${resources[$key]} $key >> $save_file
    done
    endtime=`date +'%Y-%m-%d %H:%M:%S'`
    end_seconds=$(date --date="$endtime" +%s)
    delta_seconds=$((end_seconds-start_seconds))
    hours=$((delta_seconds / 3600))
    minutes=$((delta_seconds % 3600 / 60))
    seconds=$((delta_seconds % 60))
    sed -i "5i\# Spend Time: $hours h $minutes m $seconds s " $save_file
}

# 统计函数
function main(){
    case $2 in
    GET|get)
       for f in $1;
       do
           #res=$(cat $f|awk '/GET/{print $7}'|cut -d? -f1|sort|uniq -c|awk 'BEGIN{OFS=":"}{print $1,$2}')
           res=$(cat $f|awk '/GET/{split($7,a,"?");COUNT[a[1]]++}END{for(url in COUNT){if(COUNT[url]>1) print COUNT[url]":"url}}')
           if [ -n "$res" ];then
              for r in $res;
              do
                  url=$(echo $r|cut -d: -f2)
                  count=$(echo $r|cut -d: -f1)
                  if [ -z ${resources[$url]} ];then
                     resources[$url]=$count
                  else
                     resources[$url]=$((resources[$url]+$count))                    
                  fi                  
              done
           fi
       done
    ;;
    POST|post)
       for f in $1;
       do
           #res=$(cat $f|awk '/POST/{print $7}'|cut -d? -f1|sort|uniq -c|awk 'BEGIN{OFS=":"}{print $1,$2}')
           res=$(cat $f|awk '/POST/{split($7,a,"?");COUNT[a[1]]++}END{for(url in COUNT){if(COUNT[url]>1) print COUNT[url]":"url}}')
           if [ -n "$res" ];then
              for r in $res;
              do
                  url=$(echo $r|cut -d: -f2)
                  count=$(echo $r|cut -d: -f1)
                  if [ -z ${resources[$url]} ];then 
                     resources[$url]=$count 
                  else
                     resources[$url]=$((resources[$url]+$count))
                  fi
              done
           fi
       done
    ;;
    ALL|all)
       for f in $1;
       do
           #res=$(cat $f|awk '{print $7}'|cut -d? -f1|sort|uniq -c|awk 'BEGIN{OFS=":"}{print $1,$2}')
           res=$(cat $f|awk '{split($7,a,"?");COUNT[a[1]]++}END{for(url in COUNT){if(COUNT[url]>1) print COUNT[url]":"url}}')
           if [ -n "$res" ];then
              for r in $res;
              do
                  url=$(echo $r|cut -d: -f2)
                  count=$(echo $r|cut -d: -f1)
                  if [ -z ${resources[$url]} ];then
                     resources[$url]=$count
                  else
                     resources[$url]=$((resources[$url]+$count))
                  fi
              done
           fi
       done
    esac 
}

# 主程序
var1=$1
[ -z $var2 ] && var2="--method=ALL" || var2=$2
declare -A resources
files=$(find_matched_files $var1)
action=$(echo $var2|cut -d= -f2)
starttime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s)
main "$files" $action
save_dict
