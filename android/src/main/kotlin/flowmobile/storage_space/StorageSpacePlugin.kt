package flowmobile.storage_space

import android.app.usage.StorageStatsManager
import android.content.Context
import android.os.*
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import android.os.storage.StorageManager
import android.os.storage.StorageVolume
import android.util.Log
import androidx.annotation.RequiresApi
import java.io.IOException
import java.util.UUID

/** StorageSpacePlugin */
public class StorageSpacePlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "storage_space")
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.applicationContext
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "storage_space")
      channel.setMethodCallHandler(StorageSpacePlugin())
    }
  }

  @RequiresApi(Build.VERSION_CODES.O)
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    val storageStat = getStorageStats()

    when (call.method) {
        "getLocalStorageStatistic" -> {
          val freeSpace = storageStat.first().freeSpace
          result.success(mapOf(
            "free" to freeSpace,
            "total" to storageStat.first().totalSpace,
          ))
        }
        "getAppUsedSpace" -> {
          result.success(mapOf(
            "appUsedSpace" to storageStat.first().appUsedSpace,
            "userDataSpace" to storageStat.first().userDataSpace,
            "cacheSpace" to storageStat.first().cacheSpace,
          ))
        }
        else -> {
          result.notImplemented()
        }
    }
  }

  @RequiresApi(Build.VERSION_CODES.O)
  private fun getStorageStats() : List<VolumeStats> {
    val storageManager = context.getSystemService(Context.STORAGE_SERVICE) as StorageManager
    val extDirs = Environment.getExternalStorageDirectory().listFiles()
    val storageVolumes = mutableListOf<VolumeStats>()
    run breakable@{
      extDirs.forEach { file ->
        val storageVolume = storageManager.getStorageVolume(file)
        if (storageVolume == null) {
          Log.d("StorageSpacePlugin", "Could not get storage volume for ${file.path}")
        } else {
          val totalSpace: Long
          val freeSpace: Long
          val appUsedSpace: Long
          val userDataSpace: Long
          val cacheSpace: Long

          val storageStatsManager = context.getSystemService(Context.STORAGE_STATS_SERVICE) as StorageStatsManager
          val uuid = StorageManager.UUID_DEFAULT
          val packageStats = storageStatsManager.queryStatsForPackage(uuid, context.packageName, Process.myUserHandle())
          appUsedSpace = packageStats.appBytes
          cacheSpace = packageStats.cacheBytes
          userDataSpace =  packageStats.dataBytes - cacheSpace

          if (storageVolume.isPrimary) {
            totalSpace = storageStatsManager.getTotalBytes(uuid)
            freeSpace = storageStatsManager.getFreeBytes(uuid)
          } else {
            totalSpace = file.totalSpace
            freeSpace = file.freeSpace
          }
          storageVolumes.add(VolumeStats(storageVolume, totalSpace, freeSpace, appUsedSpace, userDataSpace, cacheSpace))
          return@breakable
        }
      }
    }
    return storageVolumes
  }

  data class VolumeStats(
    val storageVolume: StorageVolume,
    val totalSpace: Long = 0,
    val freeSpace: Long = 0,
    val appUsedSpace: Long = 0,
    val userDataSpace: Long = 0,
    val cacheSpace: Long = 0,
  )

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

}
