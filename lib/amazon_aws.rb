require 'AWS'

module AmazonAws
  module EC2Instance
    def instances
      instances = []

      conn.describe_instances.reservationSet.item.each do |instance_hash|
        instance = OpenStruct.new()

        instance.reservation_id = instance_hash.reservationId
        instance.owner_id       = instance_hash.ownerId

        instance.groups = []
        instance_hash.groupSet.item.each do |groups|
          groups.each do |group|
            instance.groups << group[1]
          end
        end

        instance_hash.instancesSet.item.each do |server|
          instance.block_devices = []
          server.blockDeviceMapping.item.each do |item|
            block_device = OpenStruct.new
            block_device.volume_id             = item.ebs.volumeId
            block_device.attach_time           = item.ebs.attachTime
            block_device.status                = item.ebs.status
            block_device.device_name           = item.deviceName
            block_device.delete_on_termination = item.deleteOnTermination

            instance.block_devices << block_device
          end

          instance.key_name         = server.keyName
          instance.ramdisk_id       = server.ramdiskId
          instance.product_codes    = server.productCodes
          instance.launch_time      = server.launchTime
          instance.ami_launch_index = server.amiLaunchIndex
          instance.reason           = server.reason

          instance.kernel_id         = server.kernelId
          instance.image_id          = server.imageId
          instance.instance_type     = server.instanceType
          instance.instance_id       = server.instanceId
          instance.root_device_name  = server.rootDeviceName
          instance.root_device_type  = server.rootDeviceType
          instance.availability_zone = server.placement.availabilityZone

          instance.dns_name           = server.dnsName
          instance.private_dns_name   = server.privateDnsName
          instance.ip_address         = server.ipAddress
          instance.private_ip_address = server.privateIpAddress


          instance.architecture = server.architecture

          instance.monitoring_state = server.monitoring.state

          instance.instance_state = server.instanceState.name
          instance.instance_code  = server.instanceState.code
        end

        instances << instance
      end

      return instances
    end
  end

  class EC2
    include EC2Instance

    attr_accessor :conn
    def initialize(access_key_id, secret_access_key)
      @conn = AWS::EC2::Base.new(:access_key_id => access_key_id, :secret_access_key => secret_access_key)
    end
  end
end