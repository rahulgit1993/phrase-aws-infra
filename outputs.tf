#output "public_ip" {
#    value = aws_instance.app_server[*].public_ip
#}

#output "ec2_tags" {
#    value = aws_instance.app_server[*].tags_all.Name
#}

#output "ssh_keypair" {
#value = tls_private_key.key.private_key_pem
#sensitive = true
#}
#output "key_name" {
#value = aws_key_pair.key_pair.key_name
#}
output "public_ip" {
value = aws_instance.flask-app.public_ip
}
#output "private_ip" {
#value = aws_instance.ec2_private.private_ip
#}

#output "private_key" {
#  value     = tls_private_key.example.private_key_pem
#  sensitive = true
#}