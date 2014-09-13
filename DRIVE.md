http://codeseekah.com/tag/curl/
https://github.com/soulseekah/bash-utils/blob/master/google-oauth2/google-oauth2.sh

# Devices

Bij devices moet je 

Keys aanmaken op https://console.developers.google.com. Onder APIS & AUTH ook Drive API aanzetten. Misschien ook https://developers.google.com/apis-explorer/#p/drive/v2/

https://developers.google.com/accounts/docs/OAuth2ForDevices

curl https://accounts.google.com/o/oauth2/device/code --data "client_id=272784480583-2o7ddfn3ihkegb80gkd5qs27d2adauuo.apps.googleusercontent.com&scope=https://docs.google.com/feeds"

curl https://accounts.google.com/o/oauth2/token --data "client_id=272784480583-2o7ddfn3ihkegb80gkd5qs27d2adauuo.apps.googleusercontent.com&client_secret=nTZ1GF1xAk8kSaVcJM_abCLI&code=4/L447SnDiiuzezgDJNw9uXbM-v5tD&grant_type=http://oauth.net/grant_type/device/1.0"


curl https://accounts.google.com/o/oauth2/device/code --data "client_id=272784480583-2o7ddfn3ihkegb80gkd5qs27d2adauuo.apps.googleusercontent.com&scope=https://docs.google.com/feeds"
{
  "device_code" : "4/XaKlZP9wSR834-ESE5YCpDc6eU-1",
  "user_code" : "qfhesih8",
  "verification_url" : "https://www.google.com/device",
  "expires_in" : 1800,
  "interval" : 5
}

Device goedkeuren op https://www.google.com/device met `user_code`. 

curl https://accounts.google.com/o/oauth2/token --data "client_id=272784480583-2o7ddfn3ihkegb80gkd5qs27d2adauuo.apps.googleusercontent.com&client_secret=nTZ1GF1xAk8kSaVcJM_abCLI&code=4/XaKlZP9wSR834-ESE5YCpDc6eU-1&grant_type=http://oauth.net/grant_type/device/1.0"
{
  "access_token" : "ya29.TQB2Ezmmgwy2fCEAAADw87_9zzZUQcHKLCKmd54G6UJfSTW7Ud5P26GRtrSeM2UwQ5ft9KwH6DvYW4A90Rc",
  "token_type" : "Bearer",
  "expires_in" : 3600,
  "refresh_token" : "1/Nj5oImxANQSAtGLHetEizp4Lyhdwr4o7EC1FK26F04I"
}
curl https://www.googleapis.com/drive/v2/files -H 'Authorization: Bearer ya29.TQB2Ezmmgwy2fCEAAADw87_9zzZUQcHKLCKmd54G6UJfSTW7Ud5P26GRtrSeM2UwQ5ft9KwH6DvYW4A90Rc'
