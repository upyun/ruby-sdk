# encoding: utf-8
#------------------------------------------------------------------
#提供了人工智能相关的使用实例
#------------------------------------------------------------------

require 'upyun'

# 需要填写自己的服务名，密码，通知URL
Bucket = ''
Password = ''
Notify_Url = ''

# 需要填写上传文件路径，云端存储路径
Local_File = ''
Save_Key = ''
Save_As = ''

# 初始化一个实例
$upyun = Upyun::Form.new(Password, Bucket)

# 内容识别-图片上传预处理
def imageAsyncAudit
  # 参数详见人工智能，云存储文档
  apps = [HashWithIndifferentAccess.new({
    'name' => 'imgaudit'
  })]
  opts = HashWithIndifferentAccess.new({
    'save-key' => Save_Key,
    'notify-url' => Notify_Url,
    'apps' => apps
  })
  puts $upyun.upload(Local_File, opts)
end

# 内容识别-点播上传预处理
def videoAsyncAudit
  # 参数详见人工智能，云存储文档
  apps = [HashWithIndifferentAccess.new({
    'name' => 'videoaudit',
    'save_as' => Save_As
  })]
  opts = HashWithIndifferentAccess.new({
    'save-key' => Save_Key,
    'notify-url' => Notify_Url,
    'apps' => apps
  })
  puts $upyun.upload(Local_File, opts)
end