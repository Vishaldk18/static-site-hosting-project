terraform {
  backend "State_File_Backup" {
    bucket         = "Replace_Bucket_Name_Generated_From_Backend_Project"
    key            = "ec2-project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
