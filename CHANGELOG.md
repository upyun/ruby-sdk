## CHANGE LOG

### v1.0.9

### v1.0.8
- URI encode '[]'

### v1.0.7
- 表单上传返回的信息不论是否设置了 `return-url`, 返回信息一致

### v1.0.5
- GET 请求支持自定义 Headers
- 修正 Readme 说明
- 修正一个测试用例对 `Time.now` 的格式误用

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

