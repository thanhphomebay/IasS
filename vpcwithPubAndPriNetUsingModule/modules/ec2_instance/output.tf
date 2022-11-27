output "instances" {                                                                                                                                                                                                      
  value       = "${aws_instance.web.*.private_ip}"                                                                                                                                                                        
  description = "PrivateIP address details"                                                                                                                                                                               
}    
