# 1. הגדרת ספק הענן (AWS)
provider "aws" {
  region = "us-east-1" # בחר את האזור המועדף עליך
}

# 2. הקמת רשת מאובטחת (VPC)
# שימוש במודול רשמי ליישום Security Best Practices
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "aui-devops-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"] # כאן ירוצו השרתים בסתר
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"] # כאן יהיו ה-Load Balancers

  enable_nat_gateway = true
  single_nat_gateway = true # חוסך בעלויות עבור משימה ביתית
  
  # תגיות עבור זיהוי קל לצילומי המסך שנדרשים בהגשה
  tags = {
    Environment = "AUI-Assignment"
    Terraform   = "true"
  }
}

# 3. הקמת אשכול הקוברנטיס (EKS)
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "aui-devops-cluster"
  cluster_version = "1.29" # גרסת קוברנטיס סטנדרטית ועדכנית

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets # אבטחה: הצמתים יהיו ברשת הפרטית
  control_plane_subnet_ids = module.vpc.public_subnets

  # הגדרת סביבת ההרצה (Node Group) 
  # הגדרות אלו יעזרו לנו בסעיף הבונוס של ה-Autoscaling
  eks_managed_node_groups = {
    app_nodes = {
      min_size     = 1
      max_size     = 3 # הכנה לבדיקת עומסים והתרחבות אוטומטית
      desired_size = 2

      instance_types = ["t3.medium"]
    }
  }

  tags = {
    Environment = "AUI-Assignment"
  }
}