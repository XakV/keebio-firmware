#!/usr/bin/env ruby

class Flasher
  def initialize
    @mcu = 'm32u4'
    set_usbasp
    @port = nil
  end

  def set_avrispmkii
    @programmer = 'avrispmkii'
    @extra_params = '-B 2 -v'
  end

  def set_usbasp
    @programmer = 'usbasp'
    @extra_params = '-B 2 -v'
  end

  def flash(items)
    cmd = "avrdude -p #{@mcu} -c #{@programmer}"
    unless @port.nil?
      cmd << " -P #{@port}"
    end
    unless @extra_params.nil?
      cmd << " #{@extra_params}"
    end

    items.each do |memtype, filename|
      cmd << " -U #{memtype}:w:#{filename}"
    end
    puts cmd
    `#{cmd}`
  end

  def read(items)
    cmd = "avrdude -p #{@mcu} -c #{@programmer}"
    unless @port.nil?
      cmd << " -P #{@port}"
    end
    unless @extra_params.nil?
      cmd << " #{@extra_params}"
    end

    items.each do |memtype, filename|
      cmd << " -U #{memtype}:r:#{filename}:i"
    end
    puts cmd
    `#{cmd}`
  end

  def dfu_fuses
    { lfuse: '0x5e:m', hfuse: '0xd9:m', efuse: '0xc3:m' }
  end

  def make_avrisp_mkii_clone
    fw_file = 'AVRISP-MKII_ATmega32u4/AVRISP-MKII_ATmega32U4.hex'
    items = dfu_fuses.merge(flash: fw_file)
    flash_file(fw_file)
  end

  def flash_dfu_bootloader
    fw_file = 'BootloaderDFU-LUFA-32u4.hex'
    items = dfu_fuses.merge(flash: fw_file)
    flash(items)
  end

  def flash_iris_r3
    files = {
      flash: "#{__dir__}/iris-r3/keebio_iris_rev3_via_production.hex",
      eeprom: "#{__dir__}/iris-r3/20190603_iris.eep"
    }
    items = dfu_fuses.merge(files)
    flash(items)
  end

  def flash_iris_r3_eeprom
    flash(eeprom: 'iris-r3/20190603_iris.eep')
  end

  def flash_nyquist_r3
    files = {
      flash: "#{__dir__}/nyquist-r3/keebio_nyquist_rev3_default_production.hex",
      #eeprom: "#{__dir__}/nyquist-r3/20190603_iris.eep"
    }
    items = dfu_fuses.merge(files)
    flash(items)
  end

  def flash_usbasp
    @mcu = 'm8'
    flash_file('usbasp.2011-05-28/bin/firmware/usbasp.atmega8.2011-05-28.hex')
  end

  def view_device_info
    flash({})
  end

  def flash_file(file)
    flash(flash: file)
  end

  def read_eeprom(output_file)
    read(eeprom: output_file)
  end
end

# TODO: Add params to select action

flasher = Flasher.new()
#flasher.set_usbasp
#flasher.view_device_info
flasher.make_avrisp_mkii_clone
flasher.flash_dfu_bootloader
#flasher.flash_file('/Users/danny/syncproj/qmk/keebio_levinson_rev3_bakingpy.hex')
#flasher.flash_iris_r3
#flasher.flash_iris_r3_eeprom