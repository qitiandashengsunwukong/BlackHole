/*
 *  This file is part of BlackHole (https://github.com/Sangwan5688/BlackHole).
 * 
 * BlackHole is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BlackHole is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BlackHole.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Copyright (c) 2021-2022, Ankit Sangwan
 */

import 'package:blackhole/CustomWidgets/bouncy_playlist_header_scroll_view.dart';
import 'package:blackhole/CustomWidgets/copy_clipboard.dart';
import 'package:blackhole/CustomWidgets/gradient_containers.dart';
import 'package:blackhole/CustomWidgets/miniplayer.dart';
import 'package:blackhole/CustomWidgets/song_tile_trailing_menu.dart';
import 'package:blackhole/Services/player_service.dart';
import 'package:blackhole/Services/youtube_services.dart';
import 'package:blackhole/Services/yt_music.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';

class YouTubePlaylist extends StatefulWidget {
  final String playlistId;
  final String playlistName;
  final String? playlistSubtitle;
  final String? playlistSecondarySubtitle;
  final String playlistImage;
  const YouTubePlaylist({
    super.key,
    required this.playlistId,
    required this.playlistName,
    required this.playlistSubtitle,
    required this.playlistSecondarySubtitle,
    required this.playlistImage,
  });

  @override
  _YouTubePlaylistState createState() => _YouTubePlaylistState();
}

class _YouTubePlaylistState extends State<YouTubePlaylist> {
  bool status = false;
  List<Map> searchedList = [];
  bool fetched = false;
  bool done = true;
  List ytSearch =
      Hive.box('settings').get('ytSearch', defaultValue: []) as List;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    if (!status) {
      status = true;
      YtMusicService().getPlaylistDetails(widget.playlistId).then((value) {
        setState(() {
          searchedList = value;
          fetched = true;
        });
      });
      // YouTubeServices().getPlaylistSongs(widget.playlistId).then((value) {
      //   if (value.isNotEmpty) {
      //     setState(() {
      //       searchedList = value;
      //       fetched = true;
      //     });
      //   } else {
      //     status = false;
      //   }
      // });
    }
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext cntxt) {
    return GradientContainer(
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  if (!fetched)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else
                    BouncyPlaylistHeaderScrollView(
                      scrollController: _scrollController,
                      title: widget.playlistName,
                      subtitle: widget.playlistSubtitle,
                      secondarySubtitle: widget.playlistSecondarySubtitle,
                      imageUrl: widget.playlistImage,
                      onPlayTap: () async {
                        setState(() {
                          done = false;
                        });

                        final Map? response =
                            await YouTubeServices().formatVideoFromId(
                          id: searchedList.first['id'].toString(),
                          data: searchedList.first,
                        );
                        setState(() {
                          done = true;
                        });
                        PlayerInvoke.init(
                          songsList: [response],
                          index: 0,
                          isOffline: false,
                          recommend: false,
                        );
                        Navigator.pushNamed(context, '/player');
                      },
                      onShuffleTap: () async {
                        setState(() {
                          done = false;
                        });

                        final Map? response =
                            await YouTubeServices().formatVideoFromId(
                          id: searchedList.first['id'].toString(),
                          data: searchedList.first,
                        );
                        setState(() {
                          done = true;
                        });
                        PlayerInvoke.init(
                          songsList: [response],
                          index: 0,
                          isOffline: false,
                          recommend: false,
                        );
                        Navigator.pushNamed(context, '/player');
                      },
                      sliverList: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            if (searchedList.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20.0,
                                  top: 5.0,
                                  bottom: 5.0,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.songs,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ...searchedList.map(
                              (Map entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    left: 5.0,
                                  ),
                                  child: ListTile(
                                    leading: Card(
                                      margin: EdgeInsets.zero,
                                      elevation: 8,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          5.0,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: SizedBox.square(
                                        dimension: 50,
                                        child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          errorWidget: (context, _, __) =>
                                              const Image(
                                            fit: BoxFit.cover,
                                            image: AssetImage(
                                              'assets/cover.jpg',
                                            ),
                                          ),
                                          imageUrl: entry['image'].toString(),
                                          placeholder: (context, url) =>
                                              const Image(
                                            fit: BoxFit.cover,
                                            image: AssetImage(
                                              'assets/cover.jpg',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      entry['title'].toString(),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    onLongPress: () {
                                      copyToClipboard(
                                        context: context,
                                        text: entry['title'].toString(),
                                      );
                                    },
                                    subtitle: Text(
                                      entry['subtitle'].toString(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () async {
                                      setState(() {
                                        done = false;
                                      });

                                      final Map? response =
                                          await YouTubeServices()
                                              .formatVideoFromId(
                                        id: entry['id'].toString(),
                                        data: entry,
                                      );
                                      setState(() {
                                        done = true;
                                      });
                                      PlayerInvoke.init(
                                        songsList: [response],
                                        index: 0,
                                        isOffline: false,
                                        recommend: false,
                                      );
                                      Navigator.pushNamed(context, '/player');
                                      // for (var i = 0;
                                      //     i < searchedList.length;
                                      //     i++) {
                                      //   YouTubeServices()
                                      //       .formatVideo(
                                      //     video: searchedList[i],
                                      //     quality: Hive.box('settings')
                                      //         .get(
                                      //           'ytQuality',
                                      //           defaultValue: 'Low',
                                      //         )
                                      //         .toString(),
                                      //   )
                                      //       .then((songMap) {
                                      //     final MediaItem mediaItem =
                                      //         MediaItemConverter.mapToMediaItem(
                                      //       songMap!,
                                      //     );
                                      //     addToNowPlaying(
                                      //       context: context,
                                      //       mediaItem: mediaItem,
                                      //       showNotification: false,
                                      //     );
                                      //   });
                                      // }
                                    },
                                    trailing:
                                        YtSongTileTrailingMenu(data: entry),
                                  ),
                                );
                              },
                            ).toList(),
                          ],
                        ),
                      ),
                    ),
                  if (!done)
                    Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width / 2,
                        width: MediaQuery.of(context).size.width / 2,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: GradientContainer(
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.useHome,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.secondary,
                                    ),
                                    strokeWidth: 5,
                                  ),
                                  Text(
                                    AppLocalizations.of(context)!
                                        .fetchingStream,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
          MiniPlayer(),
        ],
      ),
    );
  }
}
