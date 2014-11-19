## CHANGE LOG

### v1.0.2
- 初始化实例的时候增加选项，特别地将连接超时时间设为 60s；
- URL `encode`, `decode` 使用 `open-uri` 代替 `uri`；
- 定义 `User-Agent` 为 `Upyun-Ruby-SDK-<VERSION>`；
- `Upyun::Rest#usage` 方法如下去掉多余的参数；

