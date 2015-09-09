# UPYUN sdk for Ruby
[![RubyGems](https://img.shields.io/gem/dtv/upyun.svg?style=flat)](https://rubygems.org/gems/upyun)
[![Build status](https://img.shields.io/travis/upyun/ruby-sdk.svg?style=flat)](https://travis-ci.org/upyun/ruby-sdk)
[![Coverage Status](https://img.shields.io/coveralls/upyun/ruby-sdk.svg)](https://coveralls.io/r/upyun/ruby-sdk)

[UPYUN](https://www.upyun.com) 官方 [Rest API](http://docs.upyun.com/api/rest_api/) 以及 [Form API](http://docs.upyun.com/api/form_api/) SDK !

> **注：**
> `0.x.x` 版本为之前第三方开发者 [veggie89](https://rubygems.org/profiles/veggie89) 开发，后续将不会维护，如果您有使用 `0.x.x` 版本，请尽快切换至 `1.x.x` 版本，以获得最新的官方 SDK 支持

## 安装

在 `Gemfile` 中加入以下代码

```ruby
gem 'upyun', '~> 1.0.8'
```

然后执行如下命令安装:

```
$ bundle
```

或者可以使用 `gem` 手动安装:

```
$ gem install upyun
```

## 基本使用

在使用本 SDK 之前，您需要拥有一个有效的 UPYUN 空间，并做好操作员的授权。详情可见 [开发者指南](http://docs.upyun.com/guide/#_2)

### Rest API 使用

#### 初始化一个实例

```ruby
require 'upyun'

upyun = Upyun::Rest.new(bucket, operator, password, options, endpoint)
```
**参数**

| 参数名  | 类型  | 可选 | 说明 |
|:-------------:|:--------:|-------:| ------------- |
| `bucket`      | `String` | 必选 | UPYUN 空间名称|
| `operator`    | `String` | 必选 | 授权操作员帐号|
| `password`    | `String` | 必选 | 授权操作员密码|
| `options`     | `Hash`   | 可选 | 连接选项，可用的选项见[RestClient::Resource](https://github.com/rest-client/rest-client/blob/master/lib/restclient/resource.rb), 默认设置超时时间 60s |
| `endpoint`    | `String` |  可选 | （默认：`Upyun::ED_AUTO`）: API接入点，可根据具体网络情况设置最优的接入点，详情见 [API 域名](http://docs.upyun.com/api/) |

其中 `endpoint` 可选值如下：

```ruby
Upyun::ED_AUTO     # 自动判断最优线路
Upyun::ED_TELECOM  # 电信接入点
Upyun::ED_UNION    # 联通（网通）接入点
Upyun::ED_CMCC     # 移动（铁通）接入点
```


> 在初始化实例后，也可以重新切换 API 接入点，方法如下：

```ruby
upyun.endpoint = Upyun::ED_CMCC
```

#### 上传文件

##### 默认方式
默认使用 Upyun 基本 Header 头上传文件:

> **注：**
> 这种方式只指定了又拍云必选的 `Date`, `Content-Length` 两个 Header，其它 Header 信息均未指定

```ruby
upyun.put('/save/to/path', File.new('file.txt', 'rb'))  # 上传一个文件
upyun.put('/save/to/path', 'binary')                    # 直接上传内容
```
**参数**

* `/save/to/path`： 文件在 UPYUN 空间的保存路径
* `file or binary`：已打开的文件描述符或文件内容，如果为文件描述符，在上传结束后该描述符会自动关闭

##### 自定义方式
您也可以选择使用 API 允许的额外可选 HTTP Header 参数，以使用 API 提供的预处理等功能：

```ruby
headers = {'Content-Type' => 'image/jpeg', 'x-gmkerl-type' => 'fix_width', 'x-gmkerl-value' => 1080}
upyun.put('/save/to/path', 'file or binary', headers)
```

其中， `/save/to/path` 和 `file or binary` 和默认上传方式中一致，`headers` 参数即为额外的可选 HTTP Header 参数，
详情查阅 [Rest API](http://docs.upyun.com/api/rest_api/#_4)

**返回**

上传成功:

  * 如果是图片空间，返回图片原信息，如 `{:height=>629, :file_type=>"JPEG", :width=>440, :frames=>1}`
  * 如果是其它空间，返回 `true`，

失败返回一个 `Hash` 结构: `{request_id: request_id, error: {code: code, message: message}}`, 其中：

* `request_id` 为本次请求的请求码，由 UPYUN 后台返回，可用该值查询 UPYUN 日志;
* `code` 为又拍云返回的错误码；
* `message` 为错误信息；


#### 下载文件

##### 获取文件内容

```ruby
file = upyun.get('/path/to/file')
```

**参数**

* `'/path/to/file'`: 文件在 UPYUN 空间中的路径

**返回**
下载成功返回文件信息，失败返回一个 `Hash`: `{request_id: request_id, error: {code: code, message: message}}`,
其中：

* `request_id` 为本次请求的请求码，由 UPYUN 本台返回，可用该值查询 UPYUN 日志;
* `code` 为又拍云返回的错误码；
* `message` 为错误信息；


##### 保存文件至本地

```ruby
upyun.get('/path/to/file', 'saved/foo.png', headers)
```

**参数**

* `'/path/to/file'`: 文件在 UPYUN 空间中的路径
* `saved/foo.png`: 文件本地保存路径
* `headers`: 指定下载时的头信息，默认为 `{}`

**返回**
下载成功返回获取的文件长度, 失败返回内容和上例一致。


#### 获取文件信息

```ruby
upyun.getinfo('/path/to/file')
```
**参数**

* `'/path/to/file'`: 文件在 UPYUN 空间中的路径

**返回**

成功返回 `Hash` 结构:

```
{file_type: "file", file_size: 397190, file_date: 1415954066}
```

其中

  * `:file_type` 说明是文件(`"file"`)还是目录(`"folder"`)
  * `:file_size` 是文件的大小
  * `:file_date` 是文件最后的更改时间。

失败返回一个 `Hash`: `{request_id: request_id, error: {code: code, message: message}}`。


#### 删除文件或者目录

```ruby
upyun.delete('/path/to/file')
```
**参数**

* `'/path/to/file'`: 文件在 UPYUN 空间中的路径

**返回**

成功返回: `true`,

失败返回一个 `Hash`: `{request_id: request_id, error: {code: code, message: message}}`。

#### 创建目录

```ruby
upyun.mkdir('/path/to/dir')
```

**参数**

* `'/path/to/dir'`: 文件在 UPYUN 空间中的路径

**返回**

成功返回: `true`,

失败返回一个 `Hash`: `{request_id: request_id, error: {code: code, message: message}}`。

#### 获取目录文件列表

```ruby
upyun.getlist('/path/to/dir')
```
**参数**

* `'/path/to/dir'`: 文件在 UPYUN 空间中的路径

**返回**
成功返回一个数组，每个数组成员为一个文件/目录:

```ruby
[{:name=>"foo", :type=>:folder, :length=>0, :last_modified=>1416193624},
 {:name=>"bar.txt", :type=>:file, :length=>25, :last_modified=>1415261057}]
```

失败返回一个 `Hash`: `{request_id: request_id, error: {code: code, message: message}}`。

#### 获取空间使用情况

```ruby
upyun.usage
```

**返回**

成功返回空间使用量（单位为 `Byte`）: `12400`,

失败返回一个 `Hash`: `{request_id: request_id, error: {code: code, message: message}}`。

### Form API 使用

#### 初始化一个实例

```ruby
require 'upyun'

upyun = Upyun::Form.new('form-api-secret', 'bucket', 'options')
```

**参数**

* `form-api-secret`: 表单 API 密钥，可通过 UPYUN 用户控制面板获取
* `bucket`: UPYUN 空间名称
* `options`: 连接选项，可用的选项见[RestClient::Resource](https://github.com/rest-client/rest-client/blob/master/lib/restclient/resource.rb), 默认设置超时时间 60s

与 Rest API 相似， 表单 API 也有个实例变量 `endpoint` 代表又拍云基本域名，默认设置为 `Upyun::ED_AUTO` ，也可以在初始化一个实例之后通过如下方式切换：

```ruby
upyun.endpoint = Upyun::ED_CMCC
```

#### 上传文件

##### 简化版
为了简化使用，又拍云文档必选的参数中:

> `save-key` 默认设置为: `'/{year}/{mon}/{day}/{filename}{.suffix}'` <br />
> `expiration` 默认设置为10分钟: `Time.now.to_i + 600`

<br />

> 使用简化版本，将不使用额外的策略参数:

```ruby
upyun.upload('filepath.png')
upyun.upload(File.new('filepath.png'))
```
参数可以是文件路径或者已经打开的文件文件描述符

**返回**
上传结果返回一个 `Hash` 结构:

```ruby
{
  :code=>200,
  :message=>"ok",
  :url=>"/2014/11/17/upyun.jpg",
  :time=>1416208715,
  :sign=>"f5165b35df431065ca54490a34028635"
}
```
其中

* `code`: 返回的状态码，`200` 为成功，其它为失败
* `message`: 错误信息，具体查阅 [表单 API 状态代码表](http://docs.upyun.com/api/form_api/#api_2)
* `url`: 上传文件保存路径
* `time`: 请求的时间戳
* `sign`: 签名参数，详情见 [sign与non-sign参数说明](http://docs.upyun.com/api/form_api/#note6)
* 如果在请求中指定了 `ext-param`, 那么返回的结构中也会有 `ext-param` 字段，详情见 [ext-param](http://docs.upyun.com/api/form_api/#note5)

##### 自定义参数
可以在上传的时候指定一些策略参数:

```ruby
opts = {
  'save-key' => '/foo/bar.jpg',
  'content-type' => 'image/jpeg',
  'image-width-range' => '0,1024',
  'return-url' => 'http://www.example.com'
}
upyun.upload('file', opts)
```
特别地，如果指定了 `return-url`, 那么返回的需要跳转的地址等信息也在这个 `Hash` 结构中，
详情查阅 [通知规则](http://docs.upyun.com/api/form_api/#notify_return)


## 贡献

1. Fork 本仓库 ( https://github.com/upyun/ruby-sdk/fork )
2. 创建您的新特性分支 (`git checkout -b my-new-feature`)
3. 提交你的更新 (`git commit -am 'Add some feature'`)
4. 同步你的代码到 GitHub 远程仓库 (`git push origin my-new-feature`)
5. 发起 Pull Request 给我们
