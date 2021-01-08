# 统计Tomcat的访问日志中每个URL出现的次数



### 该脚本主要实现对tomcat访问日志中每个URL出现的次数进行统计，并输出到JSON文件中



> 开启tomcat的访问日志功能之后，tomcat默认每天会对其进行切割。

> 遍历服务器中切割过后的的日志文件，累计所有文件中每个URL出现的次数，并输出到临时文件/tmp/statistic-GET



## 运行流程

#### (statistic.sh)统计单机数据生成临时文件 -- > (main.py)汇总临时文件返回JSON



### statistic.sh使用方法

#### 单机统计，生成临时文件

#### Usage：sh statistic.sh timestamp [options]

按年统计、只统计GET方法

sh statistic.sh 2018,2019,2020 --method=GET

按月统计、只统计POST方法

sh statistic.sh 2020-06,2020-07,2020-08 --method=POST

按指定日期统计、统计GET、与POST方法

sh statistic.sh 2020-06-09,2020-07-01 [ --method=ALL [缺省值] ]



### main.py使用方法

#### 临时文件存放在C:\Users\Administrator\Desktop\logs目录下，使用main.py汇总

> 默认会在当前Work Directory中生成JSON文件

##### python main.py --from-dir='C:\Users\Administrator\Desktop\logs'



------





