
# Création du VPC
resource "aws_vpc" "epreuve-finale" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "epreuve-finale-6243042-vpc"
  }
}

# Création des sous-réseaux

resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.epreuve-finale.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)


  tags = {
    Name = "epreuve-finale-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.epreuve-finale.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)


  tags = {
    Name = "epreuve-finale-private-${count.index + 1}"
  }
}

# Création d’une passerelle internet

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.epreuve-finale.id

  tags = {
    Name = "epreuve-finale-igw"
  }
}

# Créer des tables de routage

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.epreuve-finale.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "epreuve-finale-rtb-public"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.epreuve-finale.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "epreuve-finale-rtb-private"
  }
}

# Association sous-réseaux/tables de routage
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.private_rt.id
}







