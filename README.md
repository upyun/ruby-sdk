# UPYUN sdk for Ruby
[![RubyGems](https://img.shields.io/gem/dtv/upyun.svg?style=flat)](https://rubygems.org/gems/upyun)
[![Build status](https://img.shields.io/travis/upyun/ruby-sdk.svg?style=flat)](https://travis-ci.org/upyun/ruby-sdk)

[UPYUN](https://www.upyun.com) [Rest API](http://docs.upyun.com/api/rest_api/) 和 [Form API](http://docs.upyun.com/api/form_api/) 的 Ruby SDK !


## 安装说明

*Gemfile* 中加入以下代码

```ruby
gem 'upyun'
```

然后执行:

    $ bundle

或者可以手动安装:

    $ gem install upyun

## 基本使用

### Rest API 使用

#### 初始化一个实例

```ruby
require 'upyun'

upyun = UpYun::Rest.new('bucket', 'operator', 'password', 'endpoint')
```

其中，参数 `bucket` 为空间名称，`operator` 为授权操作员帐号, `password` 为授权操作员密码，必选。

参数 `endpoint` 为又拍云存储 API 接入点，根据国内的网络情况，又拍云存储 API 提供了电信、联通（网通）、移动（铁通）数个接入点，
在初始化时可由参数 `endpoint` 进行设置，详情查阅 [API 域名](http://docs.upyun.com/api/)。其可选的值有：

```ruby
UpYun::ED_AUTO     # 自动判断最优线路
UpYun::ED_TELECOM  # 电信接入点
UpYun::ED_UNION    # 联通（网通）接入点
UpYun::ED_CMCC     # 移动（铁通）接入点
```

默认设置为 `UpYun::ED_AUTO` ，但是我们推荐根据服务器网络状况，手动设置合理的接入点以获取最佳的访问速度。
同时，也可以在初始化一个实例之后通过：

```ruby
upyun.endpoint = UpYun::ED_CMCC
```
更改接入点。

#### 上传文件

默认使用 UpYun 基本 Header 头上传文件:

```ruby
upyun.put('/save/to/path', 'file or binary')
```
其中 `/save/to/path` 为文件保存路径，  `file or binary` 为本机上文件路径或者文件内容。
**注：**
> 这里只指定了又拍云必选的 `Date`, `Content-Length` 两个 Header，其它 Header 信息均未指定

也可以使用 UpYun 定义的额外 Header 头上传文件，详情查阅 [Rest API](http://docs.upyun.com/api/rest_api/), 如:

```ruby
headers = {'Content-Type' => 'image/jpeg', 'x-gmkerl-type' => 'fix_width', 'x-gmkerl-value' => 1080}
upyun.put('/save/to/path', 'file or binary', headers)
```

上传成功返回 `true`，失败返回一个 `Hash` 结构: `{error: {code: code, message: message}}`,
其中 `code` 为又拍云返回的错误码, `message` 为错误信息。


#### 下载文件

```ruby
file = upyun.get('/path/to/file')
```

下载成功返回文件信息，失败返回一个 `Hash`: `{error: {code: code, message: message}}`,
其中 `code` 为又拍云返回的错误码, `message` 为错误信息。

也可以指定保存路径，下载到的文件将写入到保存路径中:

```ruby
upyun.get('/path/to/file', 'saved/foo.png')
```

下载成功返回获取的文件长度。


#### 获取文件信息

```ruby
upyun.getinfo('/path/to/file')
```

成功返回 `Hash` 结构:

```
{file_type: "file", file_size: 397190, file_date: 1415954066}
```

其中

  * `:file_type` 说明是文件(`"file"`)还是目录(`"folder"`)
  * `:file_size` 是文件的大小
  * `:file_date` 是文件最后的更改时间。

失败返回一个 `Hash`: `{error: {code: code, message: message}}`。


#### 删除文件或者目录

```ruby
upyun.delete('/path/to/file')
```

成功返回: `true`,

失败返回一个 `Hash`: `{error: {code: code, message: message}}`。

#### 创建目录

```ruby
upyun.mkdir('/path/to/dir')
```

成功返回: `true`,

失败返回一个 `Hash`: `{error: {code: code, message: message}}`。

#### 获取目录文件列表

```ruby
upyun.getlist('/path/to/dir')
```

成功返回一个数组，每个数组成员为一个文件/目录:

```ruby
[{:name=>"foo", :type=>:folder, :length=>0, :last_modified=>1416193624},
 {:name=>"bar.txt", :type=>:file, :length=>25, :last_modified=>1415261057}]
```

失败返回一个 `Hash`: `{error: {code: code, message: message}}`。

#### 获取空间使用情况

```ruby
upyun.usage
```

成功返回空间使用量（单位为 `Byte`）: `12400`,

失败返回一个 `Hash`: `{error: {code: code, message: message}}`。

### Form API 使用

#### 初始化一个实例

```ruby
require 'upyun'

upyun = UpYun::Form.new('form-password', 'bucket')
```

其中，参数 `form-password` 为空间表单 API 密钥，可通过又拍云后台获取，`bucket` 为空间名称（必选）。

与 Rest API 相似， 表单 API 也有个实例变量 `endpoint` 代表又拍云基本域名，默认设置为 `UpYun::ED_AUTO` ，也可以在初始化一个实例之后通过：

```ruby
upyun.endpoint = UpYun::ED_CMCC
```
更改接入点。


#### 上传文件

为了简化使用，又拍云文档必选的参数中:
>
  `save-key` 默认设置为: `'/{year}/{mon}/{day}/{filename}{.suffix}'`
  `expiration` 默认设置为10分钟: `Time.now.to_i + 600`


使用简化版本，不使用额外的策略参数:

```ruby
upyun.upload('file')
```
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
  1. `code`: 返回的状态码，`200` 为成功，其它为失败
  2. `message`: 错误信息，具体查阅 [表单 API 状态代码表](http://docs.upyun.com/api/form_api/#api_2)
  3. `url`: 上传文件保存路径
  4. `time`: 请求的时间戳
  5. `sign`: 签名参数，详情见 [sign与non-sign参数说明](http://docs.upyun.com/api/form_api/#note6)
  6. 如果在请求中指定了 `ext-param`, 那么返回的结构中也会有 `ext-param` 字段，详情见 [ext-param](http://docs.upyun.com/api/form_api/#note5)

可以在上传的时候指定一些策略参数:

```ruby
opts = {
  'save_key' => '/foo/bar.jpg',
  'content-type' => 'image/jpeg',
  'image-width-range' => '0,1024',
  'return-url' => 'http://www.example.com'
}
upyun.upload('file', opts)
```
特别地，如果指定了 `return-url`, 那么返回的是需要跳转的地址，
详情查阅 [通知规则](http://docs.upyun.com/api/form_api/#notify_return)


## Contributing

1. Fork it ( https://github.com/[my-github-username]/upyun/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
