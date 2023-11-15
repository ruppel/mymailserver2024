function unixtime(date, time)
{
  return mktime(gensub("-", " ", "g", date)" "gensub(":", " ", "g", substr(time,1,8)))
}

function logtime(utime)
{
  return strftime("%Y-%m-%d %H:%M:%S", utime)
}

function isincluded(name)
{
  jailname = substr(name, 2, length(name)-2)
  for (elem in excluded)
  {
    if (excluded[elem]"" == jailname"") return 0
  }
  return 1
}

BEGIN {
  analyze_start = last-findtime
  split(excluded_jails, excluded, " ")
  now = systime()
  print logtime(now)" "now" Check fail2ban log"
}

(time=unixtime($1, $2)) > analyze_start &&
 $7=="Found" &&
 isincluded($6) {
  split($8, ip_adress, ".")
  first_part = ip_adress[1]"."ip_adress[2]"."ip_adress[3]
  second_part = ip_adress[4]
  if (!(first_part in found_ips)) # ignore, if already found
  {
    subnet[first_part][second_part] = time
    if (length(subnet[first_part]) > maxips)
    {
      # delete founds out of findtime
      for (elem in subnet[first_part])
      {
        if (subnet[first_part][elem] < time - findtime)
        {
          delete subnet[first_part][elem]
        }
      }
      # still over maxips?
      if (length(subnet[first_part]) > maxips && time > last)
      {
        now = systime()
        print logtime(now)" "now" Found subnet "first_part".0/24 at "$1" "$2
        found_ips[first_part] = 1
      }
    }
  }
}
