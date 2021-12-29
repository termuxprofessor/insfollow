#!/bin/bash
# insfollow v2.0
# recoded by: Termux Professor
# github.com/termuxprofessor/insfollow
# If you use any part from this code, give me the credits, please, read the License

clear
string4=$(openssl rand -hex 32 | cut -c 1-4)
string8=$(openssl rand -hex 32  | cut -c 1-8)
string12=$(openssl rand -hex 32 | cut -c 1-12)
string16=$(openssl rand -hex 32 | cut -c 1-16)
device="android-$string16"
uuid=$(openssl rand -hex 32 | cut -c 1-32)
phone="$string8-$string4-$string4-$string4-$string12"
guid="$string8-$string4-$string4-$string4-$string12"
header='Connection: "close", "Accept": "*/*", "Content-type": "application/x-www-form-urlencoded; charset=UTF-8", "Cookie2": "$Version=1" "Accept-Language": "en-US", "User-Agent": "Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)"'
var=$(curl -i -s -H "$header" https://i.instagram.com/api/v1/si/fetch_headers/?challenge_type=signup&guid=$uuid > /dev/null)
var2=$(echo $var | grep -o 'csrftoken=.*' | cut -d ';' -f1 | cut -d '=' -f2)
ig_sig="4f8732eb9ba7d1c8e8897a75d6474d4eb3f5279137431b2aafb71fafe2abe178"



banner() {
echo ""

echo -e "\e[1;91m ═╦═\e[1;92m┌─┐ ┌┌──┐\e[1;91m╔══╗\e[1;92m┌──┐┬   ┬   ┌──┐┬ ┬ ┬"

echo -e "\e[1;91m  ║ \e[1;92m│ │ ││   \e[1;91m║   \e[1;92m│  ││   │   │  ││ │ │"

echo -e "\e[1;91m  ║ \e[1;92m│ │ │└──┐\e[1;91m╠═╣ \e[1;92m│  ││   │   │  ││ │ │"

echo -e "\e[1;91m  ║ \e[1;92m┘ └─┘└──┘\e[1;91m║   \e[1;92m└──┘┴──┘┴──┘└──┘└─┴─┘"

echo -e "\e[1;91m ═╩═\e[1;92m         \e[1;91m╩   by - \e[1;92mTermux Professor"

}


login_user() {


if [[ $user == "" ]]; then
printf "\n"
printf "  \e[1;31m[\e[0m\e[1;77m*\e[0m\e[1;31m]\e[0m\e[1;93m Login\e[0m\n"
read -p $'  \e[1;31m[\e[0m\e[1;77m+\e[0m\e[1;31m]\e[0m\e[1;93m Username: \e[0m' user
fi

if [[ -e cookie.$user ]]; then

printf "  \e[1;31m[\e[0m\e[1;77m*\e[0m\e[1;31m]\e[0m\e[1;93m Cookies found for user\e[0m\e[1;77m %s\e[0m\n" $user

default_use_cookie="Y"

read -p $'  \e[1;31m[\e[0m\e[1;77m+\e[0m\e[1;31m]\e[0m\e[1;93m Use it?\e[0m\e[1;77m [Y/n]\e[0m ' use_cookie

use_cookie="${use_cookie:-${default_use_cookie}}"

if [[ $use_cookie == *'Y'* || $use_cookie == *'y'* ]]; then
printf "  \e[1;31m[\e[0m\e[1;77m*\e[0m\e[1;31m]\e[0m\e[1;93m Using saved credentials\e[0m\n"
else
rm -rf cookie.$user
login_user
fi


else

read -s -p $'  \e[1;31m[\e[0m\e[1;77m*\e[0m\e[1;31m]\e[0m\e[1;93m Password: \e[0m' pass
printf "\n"
data='{"phone_id":"'$phone'", "_csrftoken":"'$var2'", "username":"'$user'", "guid":"'$guid'", "device_id":"'$device'", "password":"'$pass'", "login_attempt_count":"0"}'

IFS=$'\n'

hmac=$(echo -n "$data" | openssl dgst -sha256 -hmac "${ig_sig}" | cut -d " " -f2)
useragent='User-Agent: "Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)"'

printf "  \e[1;77m[\e[0m\e[1;92m+\e[0m\e[1;77m] Trying to login as\e[0m\e[1;93m %s\e[0m\n" $user
IFS=$'\n'
var=$(curl -c cookie.$user -d "ig_sig_key_version=4&signed_body=$hmac.$data" -s --user-agent 'User-Agent: "Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)"' -w "\n%{http_code}\n" -H "$header" "https://i.instagram.com/api/v1/accounts/login/" | grep -o "logged_in_user\|challenge\|many tries\|Please wait" | uniq );
if [[ $var == "challenge" ]]; then printf "\e[1;93m\n[!] Challenge required\n" ; exit 1; elif [[ $var == "logged_in_user" ]]; then printf "\e[1;92m \n[+] Login Successful\n" ; elif [[ $var == "Please wait" ]]; then echo "Please wait"; fi;

fi

}


get_saved() {
user_account=$user
user_id=$(curl -L -s 'https://www.instagram.com/'$user_account'' > getid && grep -o  'profilePage_[0-9]*.' getid | cut -d "_" -f2 | tr -d '"')

printf "\e[1;77m[\e[0m\e[1;92m+\e[0m\e[1;77m] Generating image list\n"
curl -L -b cookie.$user -s --user-agent 'User-Agent: "Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)"' -w "\n%{http_code}\n" -H "$header" "https://i.instagram.com/api/v1/feed/saved" > $user_account.saved_ig

cp $user_account.saved_ig $user_account.saved_ig.00
count=0

while [[ true ]]; do
big_list=$(grep -o '"more_available": true' $user_account.saved_ig)
maxid=$(grep -o '"next_max_id": "[^ ]*.' $user_account.saved_ig | cut -d " " -f2 | tr -d '"' | tr -d ',')

if [[ $big_list == *'"more_available": true'* ]]; then

url="https://i.instagram.com/api/v1/feed/saved/?rank_token=$user_id\_$guid&max_id=$maxid"

curl -L -b cookie.$user -s --user-agent 'User-Agent: "Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)"'  -H "$header" "$url" > $user_account.saved_ig

cp $user_account.saved_ig $user_account.saved_ig.$count

unset maxid
unset url
unset big_list
else
grep -o '{"width": [0-9]*, "height": [0-9]*, "url": "https://[^ ]*' $user_account.saved_ig* | cut -d " " -f6 | cut -d '"' -f2  | cut -d "\\" -f1 | uniq > links
break

fi

let count+=1

done


if [[ ! -d $user/images ]]; then
mkdir -p $user/images
fi
tot_img=$(wc -l links | cut -d " " -f1)
count_img=0
printf "\e[1;77m[\e[0m\e[1;31m+\e[0m\e[1;77m] Total images:\e[0m\e[1;93m %s\e[0m \n" $tot_img

for img in $(cat links); do

let count_img++
printf "\e[1;77m[\e[0m\e[1;31m+\e[0m\e[1;77m] Downloading image\e[0m\e[1;93m %s/%s\e[0m " $count_img $tot_img
wget $img -O $user/images/image$count_img.jpg > /dev/null 2>&1
printf "\e[1;92mDONE!\n\e[0m"
done
printf "\e[1;77m[\e[0m\e[1;31m+\e[0m\e[1;77m] Saved:\e[0m\e[1;93m %s/images/\e[0m\n" $user

cat $user_account.saved_ig.* > $user_account.raw_saved
grep -o 'https://[^ ]*.mp4[^\ ]*.' $user_account.raw_saved | cut -d '"' -f1 | tr -d '\\' | uniq > vid_$user
count=0
tot_vid=$(wc -l vid_$user | cut -d " " -f1)
if [[ ! -d $user/videos ]]; then
mkdir -p $user/videos
fi

printf "\e[1;77m[\e[0m\e[1;31m+\e[0m\e[1;77m] Total Videos:\e[0m\e[1;93m %s\e[0m\n" $tot_vid
for link in $(cat vid_$user); do
let count++
printf "\e[1;77m[\e[0m\e[1;31m+\e[0m\e[1;77m] Downloading video\e[0m\e[1;93m %s/%s\e[0m " $count $tot_vid
printf "\e[1;92mDONE!\n\e[0m"
wget $link -O $user/videos/video$count.mp4 > /dev/null 2>&1
done

printf "\e[1;77m[\e[0m\e[1;31m+\e[0m\e[1;77m] Saved:\e[0m\e[1;93m %s/videos/\e[0m\n" $user


}

increase_followers() {

printf "\n"
printf "  \e[1;77m[\e[0m\e[1;31m+\e[0m\e[1;77m] This technique consists of following/unfolling celebgrams\e[0m\n"
printf "  \e[1;77m[\e[0m\e[1;31m+\e[0m\e[1;77m] It can increase your followers up to about +30 in 1 hour \e[0m\n"
printf "  \e[1;77m[\e[0m\e[1;31m+\e[0m\e[1;77m]\e[0m\e[1;93m Press Ctrl + C to stop \e[0m\n"
printf "\n"
sleep 5

username_id=$(curl -L -s 'https://www.instagram.com/'$user'' > getid && grep -o  'profilePage_[0-9]*.' getid | cut -d "_" -f2 | tr -d '"')

selena="460563723"
neymar="26669533"
ariana="7719696"
beyonce="247944034"
cristiano="173560420"
kimkardashian="18428658"
kendall="6380930"
therock="232192182"
kylie="12281817"
jelopez="305701719"
messi="427553890"
professor="39426961689"
dualipa="12331195"
celebrity="5457896418"
mileycyrus="325734299"
shawnmendes="212742998"
katyperry="407964088"
charlieputh="7555881"
lelepons="177402262"
camila_cabello="19596899"
madonna="181306552"
leonardodicaprio="1506607755"
ladygaga="184692323"
taylorswift="11830955"
instagram="25025320"


if [[ ! -e celeb_id ]]; then
printf " %s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n" $dualipa $celebrity $mileycyrus $shawnmendes $katyperry $charlieputh $lelepons $camila_cabello $madonna $leonardodicaprio $ladygaga $taylorswift $instagram $neymar $selena $ariana $beyonce $professor $cristiano $kimkardashian $kendall $therock $kylie $jelopez $messi > celeb_id
fi

while [[ true ]]; do


for celeb in $(cat celeb_id); do

data='{"_uuid":"'$guid'", "_uid":"'$username_id'", "user_id":"'$celeb'", "_csrftoken":"'$var2'"}'
hmac=$(echo -n "$data" | openssl dgst -sha256 -hmac "${ig_sig}" | cut -d " " -f2)
printf " \e[1;31m[\e[0m\e[1;77m+\e[0m\e[1;31m]\e[0m\e[1;93m Trying to follow celebgram %s ..." $celeb

check_follow=$(curl -s -L -b cookie.$user -d "ig_sig_key_version=4&signed_body=$hmac.$data" -s --user-agent 'User-Agent: "Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)"' -w "\n%{http_code}\n" -H "$header" "https://i.instagram.com/api/v1/friendships/create/$celeb/" | grep -o '"following": true')

if [[ $check_follow == "a" ]]; then
printf " \n\e[1;31m [!] Error\n"
printf " \n\e[1;33m [::] There is problem in you instagram account\n"
printf " \n\e[1;31m [:] Reason\n"
printf " \n\e[1;33m - You have reached today's following/unfollowing limit of instagram\n."
printf " \n\e[1;33m - You account is temporary banned by instagram\n"
printf " \n\e[1;32m [:] Solution\n"
printf " \n\e[1;33m - Don't follw or unfollow any in instagram for 24 hour then run script again it will work.\n"

exit 1
else
printf " \e[1;92mSuccess\e[0m\n"
fi
sleep 3

done
printf " \e[1;31m[\e[0m\e[1;77m+\e[0m\e[1;31m]\e[0m\e[1;77m Sleeping 60 secs...\e[0m\n"
sleep 60
#unfollow
for celeb in $(cat celeb_id); do
data='{"_uuid":"'$guid'", "_uid":"'$username_id'", "user_id":"'$celeb'", "_csrftoken":"'$var2'"}'
hmac=$(echo -n "$data" | openssl dgst -sha256 -hmac "${ig_sig}" | cut -d " " -f2)
printf " \e[1;31m[\e[0m\e[1;77m+\e[0m\e[1;31m]\e[0m\e[1;93m Trying to unfollow celebgram %s ..." $celeb
check_unfollow=$(curl -s -L -b cookie.$user -d "ig_sig_key_version=4&signed_body=$hmac.$data" -s --user-agent 'User-Agent: "Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)"' -w "\n%{http_code}\n" -H "$header" "https://i.instagram.com/api/v1/friendships/destroy/$celeb/" | grep -o '"following": false' )

if [[ $check_unfollow == "a" ]]; then
printf "\n \e[1;93m [!] Error, stoping to prevent blocking\n"
printf " \e[1;33m [-] You reached today's limit. Try tomorrow again.\n"
printf " \e[1;33m [-] We have set limit for prevent blockage of your instagram account.\n"
exit 1
else
printf " \e[1;92mSuccess\e[0m\n"
fi

sleep 3
done
printf " \e[1;31m[\e[0m\e[1;77m+\e[0m\e[1;31m]\e[0m\e[1;77m Sleeping 60 secs for block prevention...\e[0m\n"
sleep 60


done


}

menu() {

printf "\n"
printf " \e[1;31m[\e[0m\e[1;77m01\e[0m\e[1;31m]\e[0m\e[1;93m Increase Followers\e[0m\n"
printf " \e[1;31m[\e[0m\e[1;77m02\e[0m\e[1;31m]\e[0m\e[1;93m Exit\e[0m\n"
printf "\n"


read -p $' \e[1;31m[\e[0m\e[1;77m::\e[0m\e[1;31m]\e[0m\e[1;77m Choose an option: \e[0m' option

if [[ $option -eq 1 ]]; then
login_user
increase_followers

elif [[ $option -eq 2 ]]; then
printf "\n"
printf "  \e[1;91mBye Bye !!\e[0m\n"
printf "\n"
exit

else

printf " \e[1;93m[!] Invalid Option!\e[0m\n"
sleep 2
menu

fi
}


banner
menu
