# encoding: utf-8
#------------------------------------------------------------------
#提供了云处理相关的使用实例
#------------------------------------------------------------------

require 'upyun'

# 需要填写自己的服务名，密码，
Bucket = ''
Password = ''

# 需要填写通知URL, 上传文件路径，云端存储路径
Notify_Url = ''
Local_File = ''
Save_Key = ''
Save_As = ''

# 初始化一个实例
$upyun = Upyun::Form.new(Password, Bucket)

# 图片处理-同步上传预处理
def imageSyncProcess
  # 参数详见同步图片处理，云存储文档
  opts = HashWithIndifferentAccess.new({
    'save-key' => Save_Key,
    'x-gmkerl-thumb' => '/format/png'
  })
  puts $upyun.upload(Local_File, opts)
end

# 图片处理-异步上传预处理
def imageAsyncProcess
  # 参数详见异步图片处理，云存储文档
  apps = [HashWithIndifferentAccess.new({
    'name' => 'thumb',
    'x-gmkerl-thumb' => '/format/png',
    'save_as' => Save_As
  })]
  opts = HashWithIndifferentAccess.new({
    'save-key' => Save_Key,
    'notify-url' => Notify_Url,
    'apps' => apps
  })
  puts $upyun.upload(Local_File, opts)
end

# 异步音视频处理
def videoAsyncProcess
  # 参数详见异步音视频处理，云存储文档
  apps = [HashWithIndifferentAccess.new({
    'name' => 'naga',
    'type' => 'video',
    'avopts' => '/s/128x96',
    'save_as' => Save_As
  })]
  opts = HashWithIndifferentAccess.new({
    'save-key' => Save_Key,
    'notify-url' => Notify_Url,
    'apps' => apps
  })
  puts $upyun.upload(Local_File, opts)
end

# 文档转换
def uconvetAsyncProcess
  # 参数详见文档转换，云存储文档
  apps = [HashWithIndifferentAccess.new({
    name: 'uconvert',
    save_as: Save_As
  })]
  opts = HashWithIndifferentAccess.new({
    'save-key' => Save_Key,
    'notify-url' => Notify_Url,
    'apps' => apps
  })
  puts $upyun.upload(Local_File, opts)
end
