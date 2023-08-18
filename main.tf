resource "aws_instance" "example" {
  ami           = "ami-0453898e98046c639"
  instance_type = "t2.micro"

  tags = {
    Name = "Event-bridge-lambda"
  }
}

# terraform import aws_cloudwatch_event_rule.ec2-event-process ec2-event-process


resource "aws_cloudwatch_event_rule" "ec2_event_process" {
  name        = "tf-ec2-event-process"
  description = "To send ec2 status event to lambda"
  event_pattern = jsonencode(
    {
      detail = {
        instance-id = [
          aws_instance.example.id
        ]
      }
      detail-type = [
        "EC2 Instance State-change Notification"
      ]
      source = [
        "aws.ec2"
      ]
    }
  )
}

# terraform import aws_cloudwatch_event_target.example 
resource "aws_cloudwatch_event_target" "example" {
  arn  = aws_lambda_function.lambda_processor.arn
  rule = aws_cloudwatch_event_rule.ec2_event_process.id

}


