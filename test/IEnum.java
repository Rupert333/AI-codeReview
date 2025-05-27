package com.cheche365.cornerstone.entity.enums;

/**
 * 枚举基类接口
 * @author mahong
 */
public interface IEnum<V> {
    /**
     * 获取Id
     * @return id
     */
    V getId();

    /**
     * 获取名称
     * @return 名称
     */
    String getName();
}


