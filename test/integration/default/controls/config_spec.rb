control 'Prometheus configuration' do
  title 'should match desired lines'

  describe file('/etc/prometheus/prometheus.yml') do
    it { should be_file }
    it { should be_owned_by 'prometheus' }
    it { should be_grouped_into 'prometheus' }
    its('mode') { should cmp '0644' }
    its('content') { should include 'File managed by Salt' }
    its('content') { should include 'Your changes may be overwritten.' }
    its('content') { should include 'global:' }
    its('content') { should include 'alerting:' }
  end

  describe file('/opt/prometheus/textfile_exporters/ipmitool') do
    it { should be_file }
    it { should be_owned_by 'root' }
    its('mode') { should cmp '0755' }
  end
end
