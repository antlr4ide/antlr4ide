package com.github.jknack.antlr4ide.services;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

import com.google.common.base.Function;

/**
 * Guava cache conflict between Eclipse build and Maven build... until I can figure it out how to
 * use Guava without conflict ... I must fallback to something simply :S.
 *
 * @author edgar
 */
public class Caches<K, V> {

  private final int maxSize;

  private Procedure1<V> removalListener;

  public Caches(final int maxSize) {
    this.maxSize = maxSize;
  }

  public Caches<K, V> removalListener(final Procedure1<V> removalListener) {
    this.removalListener = removalListener;
    return this;
  }


  public Map<K, V> build(final Function<K, V> loader) {
    return cache(maxSize, loader, removalListener);
  }

  /**
   * Build a simple loading cache with a maxSize and an optional removal listener.
   *
   * @param maxSize The cache max size.
   * @param loader A cache loader. Required.
   * @param removalListener A removal listener. Optional.
   * @return A simple cache.
   */
  @SuppressWarnings("serial")
  private static <K, V> Map<K, V> cache(final int maxSize, final Function<K, V> loader,
      final Procedure1<V> removalListener) {
    return Collections.synchronizedMap(new LinkedHashMap<K, V>() {

      @SuppressWarnings("unchecked")
      @Override
      public V get(final Object key) {
        V value = super.get(key);
        if (value == null) {
          value = loader.apply((K) key);
          super.put((K) key, value);
        }
        return value;
      }

      @Override
      public void clear() {
        for (Map.Entry<K, V> entry : this.entrySet()) {
          if (removalListener != null) {
            removalListener.apply(entry.getValue());
          }
        }
        super.clear();
      }

      @Override
      protected boolean removeEldestEntry(final java.util.Map.Entry<K, V> eldest) {
        boolean remove = super.size() > maxSize;
        if (remove && removalListener != null) {
          removalListener.apply(eldest.getValue());
        }
        return remove;
      }
    });
  }
}
