/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package gephiimplementation;

/**
 *
 * @author marayati
 */

import java.lang.*;
import java.util.*;
/**
 *
 * @author Maede
 */
public class ArrayIndexComparator implements Comparator<Integer>
{
    private final ArrayList<Integer> array;

    public ArrayIndexComparator(ArrayList<Integer> array)
    {
        this.array = array;
    }

    public Integer[] createIndexArray()
    {
        Integer[] indexes = new Integer[array.size()];
        for (int i = 0; i < array.size(); i++)
        {
            indexes[i] = i; // Autoboxing
        }
        return indexes;
    }

    @Override
    public int compare(Integer index1, Integer index2)
    {
         // Autounbox from Integer to int to use as array indexes
        return -array.get(index1).compareTo(array.get(index2));
    }
}