###Data Prep for Shiny App###
library(mongolite)
library(stringr)
library(readr)
library(data.table)
# Load data ----
m <- mongo(collection = "AUT", db = "Twitter", url = "mongodb://127.0.0.1:27017")
data <- m$find(fields = '{"truncated" :true, "text" : true, "created_at" : true,"extended_tweet.full_text" : true, "retweeted_status.extended_tweet.full_text" : true, "user.id_str" : true, "user.name" : true, "user.lang" : true, "in_reply_to_user_id" : true, "_id" : false, "retweeted_status.truncated" : true}')
data$created_at <- as.Date(data$created_at, "%a %b %d %H:%M:%S %z %Y")

#Creating variables
data$person[str_detect(data$text, "RT @Peter_Pilz") | data$user$id_str == 168482405 | data$in_reply_to_user_id == 168482405] <- "@Peter_Pilz"
data$person[str_detect(data$text, "RT @HCStracheFP") | data$user$id_str == 117052823 | data$in_reply_to_user_id == 117052823] <- "@HCStracheFP"
data$person[str_detect(data$text, "RT @sebastiankurz") | data$user$id_str == 46623193 | data$in_reply_to_user_id == 46623193] <- "@sebastiankurz"
data$person[str_detect(data$text, "RT @SPOE_at") | data$user$id_str == 26750370 | data$in_reply_to_user_id == 26750370] <- "@SPOE_at"
data$person[str_detect(data$text, "RT @BMeinl") | data$user$id_str == 444969570 | data$in_reply_to_user_id == 444969570] <- "@BMeinl"

#Categorizing Type
data$type[data$user$id_str == 168482405] <- "Tweets"
data$type[data$user$id_str == 117052823] <- "Tweets"
data$type[data$user$id_str == 46623193] <- "Tweets"
data$type[data$user$id_str == 26750370] <- "Tweets"
data$type[data$user$id_str == 444969570] <- "Tweets"
data$type[str_detect(data$text, "RT")] <- "Retweets"
data$type[!is.na(data$in_reply_to_user_id)] <- "Comments"

#Combine 140 char text with 260 char text
data$text <- ifelse(data$retweeted_status$truncated == TRUE & !is.na(data$retweeted_status$truncated), data$retweeted_status$extended_tweet$full_text, data$text)
data$text <- ifelse(data$truncated == TRUE,data$extended_tweet$full_text, data$text)
data <- data.frame(created_at = data$created_at, text = data$text, user = data$user$name, person = data$person, type = data$type, lang = data$user$lang)

# Matching languages for select box input (list is missing some language shortcuts! update list in near future)

langref <- c(
  "Amharic" = "am",
  "Arabic" = "ar",
  "Armenian" = "hy",
  "Bengali" = "bn",
  "Bulgarian" = "bg",
  "Burmese" = "my",
  "Chinese" = "zh",
  "Czech" = "cs",
  "Danish" = "da",
  "Dutch" = "nl",
  "English" = "en",
  "Estonian" = "et",
  "Finnish" = "fi",
  "French" = "fr",
  "Georgian" = "ka",
  "German" = "de",
  "Greek" = "el",
  "Gujarati" = "gu",
  "Haitian" = "ht",
  "Hebrew" = "iw",
  "Hindi" = "hi",
  "Hungarian" = "hu",
  "Icelandic" = "is",
  "Indonesian" = "in",
  "Italian" = "it",
  "Japanese" = "ja",
  "Kannada" = "kn",
  "Khmer" = "km",
  "Korean" = "ko",
  "Lao" = "lo",
  "Latvian" = "lv",
  "Lithuanian" = "lt",
  "Malayalam" = "ml",
  "Maldivian" = "dv",
  "Marathi" = "mr",
  "Nepali" = "ne",
  "Norwegian" = "no",
  "Oriya" = "or",
  "Panjabi" = "pa",
  "Pashto" = "ps",
  "Persian" = "fa",
  "Polish" = "pl",
  "Portuguese" = "pt",
  "Romanian" = "ro",
  "Russian" = "ru",
  "Serbian" = "sr",
  "Sindhi" = "sd",
  "Sinhala" = "si",
  "Slovak" = "sk",
  "Slovenian" = "sl",
  "Sorani Kurdish" = "ckb",
  "Spanish" = "es",
  "Swedish" = "sv",
  "Tagalog" = "tl",
  "Tamil" = "ta",
  "Telugu" = "te",
  "Thai" = "th",
  "Tibetan" = "bo",
  "Turkish" = "tr",
  "Ukrainian" = "uk",
  "Urdu" = "ur",
  "Uyghur" = "ug",
  "Vietnamese" = "vi",
  "Welsh" = "cy")

langlist_logic <- langref %in% unique(data$lang)
langlist <- langref
for (i in 1:length(langlist_logic)){
  if(langlist_logic[i] == TRUE) {
    langlist[i] <- langref[i]
    names(langlist[i]) <- names(langref[i])
  } else {
    langlist[i] <- NA
  }
}
langlist <- langlist[!is.na(langlist)]
langlist <- append(langlist, c("All" = "all"), after = 0)


#Output
write_csv(data, "/srv/shiny-server/twitter/data.csv")
fwrite(as.list(langlist), "/srv/shiny-server/twitter/langlist.csv")
