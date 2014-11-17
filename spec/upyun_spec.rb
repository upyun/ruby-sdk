require File.dirname(__FILE__) + "/spec_helper"

describe "Upyun Restful API Basic testing" do
  before :all do
    @upyun = Upyun::Rest.new("sdkfile", "tester", "grjxv2mxELR3")
    @file = File.expand_path("../upyun.jpg", __FILE__)
    @str = "This is a binary string, not a file"
  end

  describe ".put" do
    before { @path = "/ruby-sdk/foo/test.jpg" }
    it "PUT a file" do
      expect(@upyun.put(@path, @file)).to be true
    end

    it "PUT a binary string" do
      expect(@upyun.put(@path, @str)).to be true
    end

    it "PUT with some extra process headers" do
      headers = {
        "Contetn-type" => "image/jpeg",
        "x-gmkerl-type" => "fix_width",
        "x-gmkerl-value" => 42,
        "x-gmkerl-unsharp" => true
      }
      expect(@upyun.put(@path, @file, headers)).to be true
    end

    after { @upyun.delete(@path) }
  end

  describe ".get" do
    before do
      @path = "/ruby-sdk/foo/test.jpg"
      @upyun.put(@path, @str, {"Content-Type" => "text/plain"})
    end

    it "GET a file" do
      expect(@upyun.get(@path)).to eq(@str)
    end

    it "GET a file and save" do
      expect(@upyun.get(@path, "./save.jpg")).not_to eq(404)
      expect(File.exists?("./save.jpg")).to be true
      expect(File.read("./save.jpg")).to eq(@str)
      File.delete("./save.jpg")
    end

    it "GET a not-exist file" do
      res = @upyun.get("/ruby-sdk/foo/test-not-exist.jpg")
      expect(res.is_a?(Hash) && res[:error][:code] == 404)
    end

    after { @upyun.delete(@path) }
  end

  describe ".delete" do
    before do
      @path = "/ruby-sdk/foo/test.jpg"
      @upyun.put(@path, @file)
    end

    it "DELETE a file" do
      expect(@upyun.delete(@path)).to be true
    end
  end

  describe ".mkdir" do
    before :all do
      @path = "/ruby-skd/foo/dir"
    end

    it "should success" do
      expect(@upyun.mkdir(@path)).to be true
    end

    after :all do
      @upyun.delete(@path)
    end
  end

  describe ".getlist" do
    it "should ok" do
      expect(@upyun.getlist("/")).to be_instance_of(Array)
    end
  end

  describe ".usage" do
    it "get space" do
      expect(@upyun.usage).to be_instance_of(Fixnum)
    end
  end
end

describe "Form Upload" do
  before :all do
    @form = Upyun::Form.new('ESxWIoMmF39nSDY7CSFUsC7s50U=', 'sdkfile')
    @file = File.expand_path("../upyun.jpg", __FILE__)
  end

  describe ".upload" do
    it "with default attributes should success" do
      res = @form.upload(@file)
      expect(res.keys).to include(:code, :message, :url, :time)
      expect(res[:code]).to eq(200)
      expect(res[:message]).to match(/ok/)
      now = Time.now
      expect(res[:url]).to eq("/#{now.year}/#{now.mon}/#{now.day}/upyun.jpg")
    end

    it "set 'save-key' should success" do
      res = @form.upload(@file, {'save-key' => 'name-ed keypath'})
      expect(res[:code]).to eq(200)
      expect(res[:url]).to eq('name-ed keypath')
    end

    it "set not correct 'expiration' should return 403 with expired" do
      res = @form.upload(@file, {'expiration' => 102400})
      expect(res[:code]).to eq(403)
      expect(res[:message]).to match(/Authorize has expired/)
    end

    it "set 'return-url' should return 302 with 'location' header" do
      res = @form.upload(@file, {'return-url' => 'http://www.example.com'})
      expect(res.code).to eq(302)
      expect(res.headers.key?(:location)).to be true
    end

    it "set 'return-url' and handle failed, should also return 302 with 'location' header" do
      opts = {
        'image-width-range' => '0,10',
        'return-url' => 'http://www.example.com'
      }
      res = @form.upload(@file, opts)
      expect(res.code).to eq(302)
      expect(res.headers.key?(:location)).to be true
    end

    it "set 'notify-url' should return 200 success", current: true do
      res = @form.upload(@file, {'notify-url' => 'http://www.example.com'})
      expect(res).to be_instance_of(Hash)
      expect(res[:code]).to eq(200)
    end

    it "set 'notify-url' and handle failed, should return 403 failed", current: true do
      opts = {
        'image-width-range' => '0,10',
        'notify-url' => 'http://www.example.com'
      }
      res = @form.upload(@file, opts)
      expect(res).to be_instance_of(Hash)
      expect(res[:code]).to eq(403)
    end
  end
end
