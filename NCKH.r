# 1. Cài đặt & load packages (chạy một lần nếu chưa có)
library(readxl)
library(dplyr)
library(urca)
library(lmtest)
library(sandwich)
library(zoo)

# 2. Đọc dữ liệu và chuẩn hóa tên cột
df_raw <- read_excel(
  "Final_dataset_with_vnindex (5).xlsx"
)

# 3. Chuyển month_year thành Date, sắp xếp, loại NA cơ bản
df <- df_raw %>%
  mutate(date = as.Date(month_year, format = "%m/%d/%y")) %>%
  arrange(date) %>%
  filter(!is.na(return), !is.na(RE))

# 4. Thống kê mô tả:
cat("Descriptive Statistics:\n")
# Chọn các cột số
numeric_columns <- df %>%
  select(where(is.numeric))

# Tính toán thống kê mô tả cho tất cả các cột số
summary_stats <- sapply(numeric_columns, function(x) {
  c(
    Min = min(x, na.rm = TRUE),
    Max = max(x, na.rm = TRUE),
    Mean = mean(x, na.rm = TRUE),
    Median = median(x, na.rm = TRUE),
    SD = sd(x, na.rm = TRUE)
  )
})

# Chuyển kết quả thành data frame để dễ nhìn
summary_stats_df <- as.data.frame(t(summary_stats))

# Hiển thị kết quả
print(summary_stats_df)

# Tính toán ma trận tương quan
correlation_matrix <- cor(numeric_columns, use = "complete.obs")

# Hiển thị ma trận tương quan
print(correlation_matrix)

# 5. Loại outlier: giữ mọi numeric có |z| ≤ 3
num_cols <- df %>% select(where(is.numeric)) %>% names()
df <- df %>%
  filter(if_all(all_of(num_cols), ~ abs((. - mean(., na.rm=TRUE)) / sd(., na.rm=TRUE)) <= 3))

# 6. Chỉ ADF để phân loại stationary vs non-stationary
vars       <- c("return","GPR","rfvn","EPU","RE","FS")
stationary <- character()
non_stat   <- character()

for(col in vars){
  x <- na.omit(df[[col]])
  if(length(x) < 5){
    warning(sprintf("Skip %s: too few obs", col))
    next
  }
  adf <- ur.df(x, type = "drift", selectlags = "AIC")
  # Lấy ADF statistic và critical value 5%
  stat_val  <- as.numeric(adf@teststat[1])
  crit_val  <- as.numeric(adf@cval[1, "5pct"])
  is_stat   <- if (!is.na(stat_val) && !is.na(crit_val)) stat_val < crit_val else FALSE
  
  cat(sprintf("%-16s ADF stat= %7.4f   5%% CV= %7.4f   Stationary? %s\n",
              col, stat_val, crit_val, ifelse(is_stat,"Yes","No")))
  
  if(is_stat) stationary <- c(stationary, col)
  else          non_stat   <- c(non_stat, col)
}

cat("\nStationary:    ", paste(stationary, collapse = ", "), "\n")
cat("Non-stationary:", paste(non_stat,   collapse = ", "), "\n\n")

# 7. Tạo sai phân cho biến non-stationary và loại NA
for(col in non_stat){
  df[[paste0(col, "_diff")]] <- c(NA, diff(df[[col]]))
}
# Xóa hàng có NA mới sinh
diff_cols <- paste0(non_stat, "_diff")
df <- df %>% filter(if_all(all_of(diff_cols), ~ !is.na(.)))

# 8. Kiểm tra lại các chuỗi dừng đã sai phân
for(col in diff_cols){
  x <- df[[col]]
  # đảm bảo không có NA
  x <- na.omit(x)
  if(length(x) < 5){
    cat(sprintf("%-20s: too few obs, skip\n", col))
    next
  }
  adf <- ur.df(x, type = "drift", selectlags = "AIC")
  stat_val <- as.numeric(adf@teststat[1])          # ADF statistic
  crit_val <- as.numeric(adf@cval[1, "5pct"])      # 5% critical value
  is_stat  <- stat_val < crit_val
  cat(sprintf(
    "%-20s ADF stat = %7.4f   5%% CV = %7.4f   => %s\n",
    col, stat_val, crit_val, ifelse(is_stat, "Stationary", "Non-stationary")
  ))
}

# 9. Công thức hồi quy
formula <- return ~ 
  GPR + RE + EPU + rfvn_diff + FS_diff

# 10. Ước lượng OLS
ols <- lm(formula, data = df)

# 11. Tính lag HAC rule-of-thumb
n       <- length(residuals(ols))
lag_opt <- floor(4 * (n / 100)^(2/9))
cat("Optimal HAC lag:", lag_opt, "\n\n")

# 12. In kết quả Newey–West HAC
cat("\n--- OLS với Newey–West HAC (lag =", lag_opt, ") ---\n")
print(summary(ols, vcov = NeweyWest(ols, lag = lag_opt, prewhite = FALSE)))

# 13. Kiểm định BP-Test (Breusch-Pagan Test) - kiểm tra tính đồng nhất của phương sai
bp_test <- bptest(ols)
cat("\n--- Breusch-Pagan Test ---\n")
print(bp_test)

# 14. Kiểm định BG-Test (Breusch-Godfrey Test) - kiểm tra sự tự tương quan trong phần dư
bg_test <- bgtest(ols, order = 3) 
cat("\n--- Breusch-Godfrey Test ---\n")
print(bg_test)

# 15. Kiểm định Ramsey RESET - kiểm tra sự phù hợp của mô hình
reset_test <- resettest(ols)
cat("\n--- Ramsey RESET Test ---\n")
print(reset_test)

# 16. Kiểm tra đa cộng tuyến (VIF)
vif_result <- vif(ols)
cat("\n--- Variance Inflation Factor (VIF) ---\n")
print(vif_result)

# 17. Kiểm định Shapiro-Wilk - kiểm tra tính chuẩn của phần dư
shapiro_test <- shapiro.test(residuals(ols))
cat("\n--- Shapiro-Wilk Test ---\n")
print(shapiro_test)
