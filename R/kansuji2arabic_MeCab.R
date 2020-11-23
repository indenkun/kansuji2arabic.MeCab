#' Convert kansuji to Arabic numerals with MeCab
#' @description
#' Converts a given kansuji to arabic mumerals with MeCab.
#' `kansuji2arabic_str()` converts kansuji in a string to numbers represented by kansuji while
#' retaining the non-kansuji characters with MeCab.
#' @param str Input vector.
#' @param consecutive If you select "convert", any sequence of 1 to 9 kansuji will
#'  be replaced with Arabic numerals. If you select "non", any sequence of 1-9
#'  kansuji will not be replaced by Arabic numerals.
#' @param widths If you select "all", both full-width and half-width Arabic numerals
#'  are taken into account when calculating kansuji, but if you select "halfwidth",
#'  only half-width Arabic numerals are taken into account when calculating kansuji.
#' @param ... Other arguments to carry over.
#' @rdname kansuji2arabic_MeCab
#' @return a character.
#' @importFrom purrr map_chr
#' @export
#'

kansuji2arabic_str_MeCab <- function(str, consecutive = c("convert", "non"), widths = c("all", "halfwidth"), ...){
  consecutive <- match.arg(consecutive)
  widths <- match.arg(widths)

  purrr::map_chr(str, kansuji2arabic_MeCab, ...)
}

#' @importFrom stringr str_split
#' @importFrom stringr str_replace_all
#' @importFrom stringr str_detect
#' @importFrom stringr str_length
#' @importFrom stringr str_c
#' @importFrom RMeCab RMeCabText
#' @importFrom zipangu kansuji2arabic_num
#' @importFrom arabic2kansuji arabic2kansuji
#' @importFrom stats na.omit
#' @importFrom utils capture.output
#'
kansuji2arabic_MeCab <- function(str, consecutive = c("convert", "non"), widths = c("all", "halfwidth"), ...){
  if(length(str) > 1) stop("only one strings can convert to kansuji.")
  consecutive <- match.arg(consecutive)
  widths <- match.arg(widths)

  if(widths == "all"){
    arabicn_half <- "1234567890"
    arabicn_full <- "\uff11\uff12\uff13\uff14\uff15\uff16\uff17\uff18\uff19\uff10"

    arabicn_half <- unlist(stringr::str_split(arabicn_half, ""))
    arabicn_full <- unlist(stringr::str_split(arabicn_full, ""))

    names(arabicn_half) <- arabicn_full
    str <- stringr::str_replace_all(str, arabicn_half)
  }

  tmpf <- tempfile()
  write(str, tmpf)
  invisible(utils::capture.output(RMeCab_res <- RMeCab::RMeCabText(tmpf)))
  str_kansuji <- NULL
  str_nonkansuji <- NULL

  if(length(RMeCab_res) == 1){
    if(stringr::str_detect(RMeCab_res[[1]][1], pattern = "[\u96f6\u3007\u4e00\u4e8c\u4e09\u56db\u4e94\u516d\u4e03\u516b\u4e5d\u5341\u767e\u5343\u4e07\u5104\u5146\u4eac]")) return(kansuji2arabic_num(str))
    else return(str)
  }

  for(i in 1:length(RMeCab_res)){
    if(RMeCab_res[[i]][3] == "\u6570" &&
       stringr::str_detect(RMeCab_res[[i]][1], pattern = "[\u96f6\u3007\u4e00\u4e8c\u4e09\u56db\u4e94\u516d\u4e03\u516b\u4e5d]") &&
       stringr::str_length(RMeCab_res[[i]][1] > 1)) RMeCab_res[[i]][1] <- kansuji2arabic_num(RMeCab_res[[i]][1], ...)

    if(RMeCab_res[[i]][3] == "\u6570" &&
       stringr::str_detect(RMeCab_res[[i]][1], pattern = "[0123456789]")) RMeCab_res[[i]][1] <- arabic2kansuji::arabic2kansuji(RMeCab_res[[i]][1])

    if(RMeCab_res[[i]][3] == "\u6570" &&
       stringr::str_detect(RMeCab_res[[i]][1], pattern = "[^0123456789]") &&
       stringr::str_detect(RMeCab_res[[i]][1], pattern = "[^\uff11\uff12\uff13\uff14\uff15\uff16\uff17\uff18\uff19\uff10]")){
      str_kansuji[i] <- RMeCab_res[[i]][1]
      str_nonkansuji[i] <- ""
    }else{
      str_nonkansuji[i] <- RMeCab_res[[i]][1]
      str_kansuji[i] <- "\u30c0"
    }
  }

  str_kansuji <- stringr::str_c(str_kansuji, collapse = "")
  str_kansuji <- stringr::str_split(str_kansuji, pattern = "[^\u96f6\u3007\u4e00\u4e8c\u4e09\u56db\u4e94\u516d\u4e03\u516b\u4e5d\u5341\u767e\u5343\u4e07\u5104\u5146\u4eac]")[[1]]
  str_kansuji[str_kansuji == ""] <- NA
  str_kansuji <- zipangu::kansuji2arabic_num(stats::na.omit(str_kansuji), consecutive, ...)

  j <- 1

  for(i in 1:length(str_nonkansuji)){
    if(!stringr::str_detect(str_nonkansuji[i], pattern = "") && i == 1){
      str_nonkansuji[i] <- str_kansuji[j]
      j <- j + 1
    }
    else if(consecutive == "non"){
      if((stringr::str_detect(str_nonkansuji[i - 1], pattern = "[^0123456789]")
          && stringr::str_detect(str_nonkansuji[i - 1], pattern = "[^\u96f6\u3007\u4e00\u4e8c\u4e09\u56db\u4e94\u516d\u4e03\u516b\u4e5d]"))
         && !stringr::str_detect(str_nonkansuji[i], pattern = "")){
        str_nonkansuji[i] <- str_kansuji[j]
        j <- j + 1
      }
    }
    else if(stringr::str_detect(str_nonkansuji[i - 1], pattern = "[^0123456789]")
            && !stringr::str_detect(str_nonkansuji[i], pattern = "")){
      str_nonkansuji[i] <- str_kansuji[j]
      j <- j + 1
    }
    if((length(str_kansuji) + 1)  ==  j) break
  }
  ans <- stringr::str_c(stats::na.omit(str_nonkansuji), collapse = "")
  return(ans)

}
