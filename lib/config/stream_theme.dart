import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'constants.dart';

class LionStreamTheme {
  static StreamChatThemeData forBrightness(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return isDark ? dark() : light();
  }

  static StreamChatThemeData dark() {
    return StreamChatThemeData.dark().copyWith(
      colorTheme: StreamColorTheme.dark(
        accentPrimary: LionColors.primary,
        appBg: LionColors.backgroundDark,
        barsBg: LionColors.surfaceDark,
        borders: LionColors.borderDark,
        overlayDark: Colors.black54,
      ),
      ownMessageTheme: StreamMessageThemeData(
        messageBackgroundColor: LionColors.primary,
        messageTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          height: 1.45,
        ),
        createdAtStyle: TextStyle(
          color: Colors.white.withOpacity(0.55),
          fontSize: 10,
        ),
        messageBorderColor: Colors.transparent,
        reactionsBackgroundColor: LionColors.surfaceDark,
        reactionsBorderColor: LionColors.borderDark,
        reactionsMaskColor: LionColors.surfaceDark,
      ),
      otherMessageTheme: StreamMessageThemeData(
        messageBackgroundColor: LionColors.theirBubbleDark,
        messageTextStyle: const TextStyle(
          color: LionColors.textPrimaryDark,
          fontSize: 15,
          height: 1.45,
        ),
        createdAtStyle: TextStyle(
          color: LionColors.textSecondaryDark.withOpacity(0.6),
          fontSize: 10,
        ),
        messageBorderColor: LionColors.borderDark,
        reactionsBackgroundColor: LionColors.surfaceDark,
        reactionsBorderColor: LionColors.borderDark,
      ),
      messageInputTheme: StreamMessageInputThemeData(
        borderRadius: BorderRadius.circular(24),
        inputBackgroundColor: const Color(0xFF1E1E35),
        inputTextStyle: const TextStyle(
          color: LionColors.textPrimaryDark,
          fontSize: 15,
        ),
        sendAnimationDuration: const Duration(milliseconds: 300),
        actionButtonColor: LionColors.primary,
        sendButtonColor: LionColors.primary,
        expandButtonColor: LionColors.textSecondaryDark,
        idleSendButton: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF1E1E35),
          ),
          child: Icon(
            Icons.mic_rounded,
            color: LionColors.textSecondaryDark.withOpacity(0.6),
            size: 18,
          ),
        ),
        activeSendButton: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LionColors.primaryGradient,
          ),
          child: const Icon(
            Icons.send_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
      channelPreviewTheme: StreamChannelPreviewThemeData(
        avatarTheme: StreamAvatarThemeData(
          borderRadius: BorderRadius.circular(26),
          constraints: const BoxConstraints(
            minHeight: 52,
            minWidth: 52,
            maxHeight: 52,
            maxWidth: 52,
          ),
        ),
        titleStyle: const TextStyle(
          color: LionColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        subtitleStyle: TextStyle(
          color: LionColors.textSecondaryDark.withOpacity(0.7),
          fontSize: 13,
        ),
        lastMessageAtStyle: TextStyle(
          color: LionColors.textSecondaryDark.withOpacity(0.5),
          fontSize: 11,
        ),
        unreadCounterColor: LionColors.primary,
        indicatorIconSize: 14,
      ),
    );
  }

  static StreamChatThemeData light() {
    return StreamChatThemeData.light().copyWith(
      colorTheme: StreamColorTheme.light(
        accentPrimary: LionColors.primary,
        appBg: LionColors.backgroundLight,
        barsBg: LionColors.surfaceLight,
        borders: LionColors.borderLight,
      ),
      ownMessageTheme: StreamMessageThemeData(
        messageBackgroundColor: LionColors.primary,
        messageTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          height: 1.45,
        ),
        createdAtStyle: TextStyle(
          color: Colors.white.withOpacity(0.55),
          fontSize: 10,
        ),
        messageBorderColor: Colors.transparent,
        reactionsBackgroundColor: LionColors.surfaceLight,
        reactionsBorderColor: LionColors.borderLight,
        reactionsMaskColor: LionColors.surfaceLight,
      ),
      otherMessageTheme: StreamMessageThemeData(
        messageBackgroundColor: LionColors.theirBubbleLight,
        messageTextStyle: const TextStyle(
          color: LionColors.textPrimaryLight,
          fontSize: 15,
          height: 1.45,
        ),
        createdAtStyle: TextStyle(
          color: LionColors.textSecondaryLight.withOpacity(0.6),
          fontSize: 10,
        ),
        messageBorderColor: LionColors.borderLight,
      ),
      messageInputTheme: StreamMessageInputThemeData(
        borderRadius: BorderRadius.circular(24),
        inputBackgroundColor: const Color(0xFFF3F4F6),
        inputTextStyle: const TextStyle(
          color: LionColors.textPrimaryLight,
          fontSize: 15,
        ),
        actionButtonColor: LionColors.primary,
        sendButtonColor: LionColors.primary,
        idleSendButton: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.06),
          ),
          child: Icon(
            Icons.mic_rounded,
            color: LionColors.textSecondaryLight.withOpacity(0.6),
            size: 18,
          ),
        ),
        activeSendButton: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LionColors.primaryGradient,
          ),
          child: const Icon(
            Icons.send_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
      channelPreviewTheme: StreamChannelPreviewThemeData(
        avatarTheme: StreamAvatarThemeData(
          borderRadius: BorderRadius.circular(26),
          constraints: const BoxConstraints(
            minHeight: 52,
            minWidth: 52,
            maxHeight: 52,
            maxWidth: 52,
          ),
        ),
        titleStyle: const TextStyle(
          color: LionColors.textPrimaryLight,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        subtitleStyle: const TextStyle(
          color: LionColors.textSecondaryLight,
          fontSize: 13,
        ),
        lastMessageAtStyle: TextStyle(
          color: LionColors.textSecondaryLight.withOpacity(0.5),
          fontSize: 11,
        ),
        unreadCounterColor: LionColors.primary,
      ),
    );
  }
}
