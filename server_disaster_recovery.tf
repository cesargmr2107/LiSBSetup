/* SERVER DISASTER RECOVERY */

/* AUTOMATED SNAPSHOT CREATION WITH LIFECYCLE MANAGER */

resource "aws_iam_role" "dlm_lifecycle_role" {
    name = "dlm_lifecycle_role"

    assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "dlm.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
            }
        ]
    })
}

resource "aws_iam_role_policy" "dlm_lifecycle_policy" {
    name = "dlm_lifecycle_policy"
    role = aws_iam_role.dlm_lifecycle_role.id

    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                "ec2:CreateSnapshot",
                "ec2:CreateSnapshots",
                "ec2:DeleteSnapshot",
                "ec2:DescribeInstances",
                "ec2:DescribeVolumes",
                "ec2:DescribeSnapshots"
                ],
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": [
                "ec2:CreateTags"
                ],
                "Resource": "arn:aws:ec2:*::snapshot/*"
            }
        ]
    })
}

resource "aws_dlm_lifecycle_policy" "DLMAutomatedSnapshots" {
  description        = "Automated EBS snapshots with DLM"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["INSTANCE"]

    schedule {
      name = "Every 6 hours and only 10 snapshots retained"

      create_rule {
        interval      = 6
        interval_unit = "HOURS"
        times         = ["00:00"]
      }

      retain_rule {
        count = 10
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      copy_tags = false
    }

    target_tags = {
      Snapshot = "true"
    }
  }
}

/* AUTO RECOVERY */

/* Notifications */

resource "aws_sns_topic" "ServerRecoveryTopic" {
	name = "ServerRecoveryTopic"
}

resource "aws_sns_topic_subscription" "ServerRecoveryEmailSubscription" {
	topic_arn = "${aws_sns_topic.ServerRecoveryTopic.arn}"
	protocol  = "email"
	endpoint  = "${var.sns_email}"
}

/* CloudWatch Alarm that monitors system status check and triggers autorecovery in case the check fails */

resource "aws_cloudwatch_metric_alarm" "ServerRecoveryAlarm" {
	alarm_name                = "ServerRecoveryAlarm"
	comparison_operator       = "GreaterThanOrEqualToThreshold"
	evaluation_periods        = "1"
	metric_name               = "StatusCheckFailed_System"
	namespace                 = "AWS/EC2"
	period                    = "300"
	statistic                 = "Average"
	threshold                 = "0.99"
	alarm_description         = "This alarm triggers server recovery when system status check fails"
	
	dimensions = {
		InstanceId = "${aws_instance.SpamFilterServer.id}"
	}
	
	alarm_actions = [
		"${aws_sns_topic.ServerRecoveryTopic.arn}",
		"arn:aws:automate:${var.aws_region}:ec2:recover"
	]
}