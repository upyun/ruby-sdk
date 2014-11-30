## CHANGE LOG

### v1.0.4
- 修正上传的参数为文件内容或者是文件描述符
- ActiveSupport 的依赖放宽到 3.2.8 或以上

### v1.0.3
- 请求失败时返回的 Hash 中增加 `:request_id` 字段；
- 对于图片空间，上传时返回的 Hash 中包含图片详情信息；
- 删除不必要的 gem 依赖；

### v1.0.2
- 初始化实例的时候增加选项，特别地将连接超时时间设为 60s；
- URL `encode`, `decode` 使用 `open-uri` 代替 `uri`；
- 定义 `User-Agent` 为 `Upyun-Ruby-SDK-<VERSION>`；
- `Upyun::Rest#usage` 方法如下去掉多余的参数；

