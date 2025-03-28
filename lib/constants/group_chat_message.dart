import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:chatapp/constants/colors.dart';
import 'package:chatapp/constants/formate_date.dart';
import 'package:chatapp/models/group_message_model.dart';

class GroupChatMessage extends StatefulWidget {
  final GroupMessageModel msg;
  final String currentUser;
  final bool isImage;
  const GroupChatMessage({
    super.key,
    required this.msg,
    required this.currentUser,
    required this.isImage,
  });

  @override
  State<GroupChatMessage> createState() => _GroupChatMessageState();
}

class _GroupChatMessageState extends State<GroupChatMessage> {
  @override
  Widget build(BuildContext context) {
    return widget.msg.isImage == true
        ? Container(
          child: Row(
            mainAxisAlignment:
                widget.msg.senderId == widget.currentUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            children: [
              if (widget.msg.senderId != widget.currentUser)
                CircleAvatar(
                  backgroundImage:
                      widget.msg.userData[0].profilePic == "" ||
                              widget.msg.userData[0].profilePic == null
                          ? Image(image: AssetImage("assets/user.png")).image
                          : CachedNetworkImageProvider(
                            "https://cloud.appwrite.io/v1/storage/buckets/662faabe001a20bb87c6/files/${widget.msg.userData[0].profilePic}/view?project=662e8e5c002f2d77a17c&mode=admin",
                          ),
                ),
              Column(
                crossAxisAlignment:
                    widget.msg.senderId == widget.currentUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                children: [
                  if (widget.msg.senderId != widget.currentUser)
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        widget.msg.userData[0].name ?? "No Name",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Container(
                    margin: EdgeInsets.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl:
                            "https://cloud.appwrite.io/v1/storage/buckets/662faabe001a20bb87c6/files/${widget.msg.message}/view?project=662e8e5c002f2d77a17c&mode=admin",
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 3),
                        child: Text(
                          formatDate(widget.msg.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        )
        : Container(
          padding: EdgeInsets.all(4),
          child: Row(
            mainAxisAlignment:
                widget.msg.senderId == widget.currentUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            children: [
              if (widget.msg.senderId != widget.currentUser)
                CircleAvatar(
                  backgroundImage:
                      widget.msg.userData[0].profilePic == "" ||
                              widget.msg.userData[0].profilePic == null
                          ? Image(image: AssetImage("assets/user.png")).image
                          : CachedNetworkImageProvider(
                            "https://cloud.appwrite.io/v1/storage/buckets/662faabe001a20bb87c6/files/${widget.msg.userData[0].profilePic}/view?project=662e8e5c002f2d77a17c&mode=admin",
                          ),
                ),
              Column(
                crossAxisAlignment:
                    widget.msg.senderId == widget.currentUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                children: [
                  if (widget.msg.senderId != widget.currentUser)
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        widget.msg.userData[0].name ?? "No Name",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color:
                              widget.msg.senderId == widget.currentUser
                                  ? kPrimaryColor
                                  : kSecondaryColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft:
                                widget.msg.senderId == widget.currentUser
                                    ? Radius.circular(20)
                                    : Radius.circular(2),
                            bottomRight:
                                widget.msg.senderId == widget.currentUser
                                    ? Radius.circular(2)
                                    : Radius.circular(20),
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Text(
                          widget.msg.message,
                          style: TextStyle(
                            color:
                                widget.msg.senderId == widget.currentUser
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 3),
                        child: Text(
                          formatDate(widget.msg.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
  }
}
