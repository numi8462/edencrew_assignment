/// 관심 화면 정렬 기준.
enum WatchlistSort { priceDesc, changeRateDesc, nameAsc }

extension WatchlistSortX on WatchlistSort {
  String get label => switch (this) {
        WatchlistSort.priceDesc => '현재가순',
        WatchlistSort.changeRateDesc => '등락률순',
        WatchlistSort.nameAsc => '가나다순',
      };
}
