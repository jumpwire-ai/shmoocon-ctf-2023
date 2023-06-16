# shmoocon-ctf-2023

This is the setup and code for the challenges from JumpWire's Shmoocon 2023 CTF.

If you'd like to read more about the event, it's detailed [here](https://jumpwire.io/blog/how-to-run-a-ctf)

## Structure

All of the challenges live in `challenges`. At a minimum, each has its own README and a `challenge.yml` file that provides metadata for ctfcli.

Terraform resources are located in `*.tf` files as well as the `modules` directory.

## Deploying

For the most part, these challenges are not templatized. They are here as a record but some work needs to be done to make them deployable in your infrastructure. At a bare minimum, the following would need to be updated:

- all DNS records
- fly app names
- terraform S3 buckets
- AWS accounts
- AWS profiles in challenge-specific terraform code
- allowed IPs in ip-whitelist.txt (only for AWS challenges)

## The story

ChatGPT generated novella to give the scoreboard story a bit of whimsy.

### Background

The General Data Protection Regulation (GDPR) is a set of laws that protect the privacy of individuals in the European Union (EU). One of the main goals of the GDPR is to ensure that individuals have the right to report any concerns or issues related to the processing of their personal data. This includes the right to report any breaches of the GDPR or other illegal activity related to the processing of personal data.

The GDPR provides specific protections for whistleblowers, including the right to report concerns anonymously and the right to not be subject to retaliation for making a report. The GDPR Commissioner is responsible for enforcing the GDPR and ensuring that individuals' rights are protected. As such, the GDPR Commissioner may support a whistleblower in order to ensure that any concerns or issues related to the processing of personal data are properly addressed and that individuals' rights are protected.

### Letter from whistleblower

Dear GDPR Commissioner,

I am writing to report a potential violation of the General Data Protection Regulation (GDPR) by Mugtome. I am a whistleblower and wish to remain anonymous for my own safety.

I have been working for Mugtome for the past year and have observed several instances of the company potentially violating the GDPR. Specifically, I have seen the following actions:

- Mugtome collecting and processing personal data from users without their explicit consent
- Mugtome sharing personal data with third parties without disclosing this to users
- Mugtome failing to properly secure personal data, leading to potential data breaches

I have concerns about these actions and believe that they may be in violation of the GDPR. In order to protect myself and the evidence I have collected, I have hidden it in several esoteric locations that only I know about. I am willing to provide more information and assistance in this matter, but I must remain anonymous for my own safety. Please contact me through a secure channel to arrange for the retrieval of the evidence.

Thank you for your attention to this matter.

Sincerely,
[Anonymous]
