add-type @"
	using System.Net;
	using System.Security.Cryptography.X509Certificates;
	public class TrustAllCertsPolicy : ICertificatePolicy {
		public bool CheckValidationResult(
		ServicePoint srvPoint, X509Certificate certificate,
		WebRequest request, int certificateProblem) {
			return true;
		}
	}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Ssl3, [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12
$Website = $args[0]

try {
	$WebRequest = [Net.HttpwebRequest]::Create($Website)
	$WebRequest.Timeout = 5000
	$WebRequest.GetResponse() | Out-Null
	$SSLCertificateExpirationDateString = $webRequest.ServicePoint.Certificate.GetExpirationDateString()
	$SSLCertificateDateTime = [Datetime]::ParseExact($SSLCertificateExpirationDateString, "dd/MM/yyyy HH:mm:ss", $null)
	$SSLCertificateDaysRemaining = ($SSLCertificateDateTime - $(Get-Date)).Days
	
	Write-Host $SSLCertificateDaysRemaining
}

catch {
	Write-Host "ERROR|$error"
}